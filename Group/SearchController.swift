//
//  SearchController.swift
//  Group
//
//  Created by Hoang Le on 9/20/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKCoreKit
import APAddressBook
import DigitsKit
//import Permission


class SearchController: UITableViewController {
    // MARK: - Properties
    //    var detailViewController: DetailViewController? = nil
    var users = [User]()
    var filteredUsers = [User]()
    var userkeys = [String:User]()
    let searchController = UISearchController(searchResultsController: nil)
    let ref = FIRDatabase.database().reference()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 9.0, *) {
//            let permission: Permission = .Contacts
//            
//            print(permission.status) // PermissionStatus.NotDetermined
//            
//            permission.request { status in
//                switch status {
//                case .Authorized:    print("authorized")
//                case .Denied:        print("denied")
//                case .Disabled:      print("disabled")
//                case .NotDetermined: print("not determined")
//                }
//            }
//            
//        } else {
//            // Fallback on earlier versions
//        }
        
        
        ref.child("users").child(AppDelegate.currentUser.uid).observeEventType(.Value, withBlock: { snapshot in
            self.tableView.reloadRowsAtIndexPaths(self.users.enumerate().map{ (index, element) in
                    return NSIndexPath(forRow:index, inSection: 0)
                },
                withRowAnimation: .Automatic)
        })
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for friends"
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        // Load facebook friends
        
        let request = FBSDKGraphRequest(graphPath:"me/friends", parameters: ["fields": "name", "limit":"200"] );
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil {
                
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let fb = valueDict.valueForKey("id") as! String
                    
                    self.ref.child("users").queryOrderedByChild("fb").queryEqualToValue(fb).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        let user = User(snapshot: snapshot.children.allObjects.first as! FIRDataSnapshot)
                        
                        if self.userkeys[user.uid] == nil{
                            self.users.append(user)
                            self.userkeys[user.uid] = user
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.users.count - 1, inSection: 0)],
                                withRowAnimation: .Automatic)
                            
                            print("Found fb \(user.name)")
                        }
                        
                    }) { (error) in
                        print(error)
                    }
                    
                }
            } else {
                print(error);
            }
        }
        
        
        // Load contacts friends
        let addressBook = APAddressBook()
        addressBook.loadContacts({(contacts, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            for contact in contacts! {
                
                if let phones = contact.phones {
                    for phone in phones {
                        var number = phone.number!.removeWhitespace()
                        if number.hasPrefix("0"){
                            number = "+84" + String(number.characters.dropFirst())
                        }
                        
                        if AppDelegate.currentUser != nil && number == AppDelegate.currentUser.phone {
                            continue
                        }
                        
                        self.ref.child("users").queryOrderedByChild("phone").queryEqualToValue(number).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let snap = snapshot.children.allObjects.first as? FIRDataSnapshot {
                                let user = User(snapshot: snap)
                                
                                if user.uid != AppDelegate.currentUser.uid && self.userkeys[user.uid] == nil {
                                    self.users.append(user)
                                    self.userkeys[user.uid] = user
                                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.users.count - 1, inSection: 0)],
                                        withRowAnimation: .Automatic)
                                    
                                    print("Found contact \(user.name)")
                                }
                                
                            }
                            
                        }) { (error) in
                            print(error)
                        }
                        
                    }
                }
                
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = SearchItemCell()
        var user: User
        if searchController.active && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        // Set cell data
        cell.nameLabel.text = user.name
        
        let imgUrl = NSURL(string: "https://graph.facebook.com/\(user.fb)/picture?type=large&return_ssl_resources=1")
        cell.profileImg.kf_setImageWithURL(imgUrl)
        
        if AppDelegate.currentUser.following[user.uid] != nil && AppDelegate.currentUser.following[user.uid] == true {
            cell.followButton.setTitle("unfollow", forState: .Normal)
            cell.followButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else {
            cell.followButton.setTitle("follow", forState: .Normal)
            cell.followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            
        }
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(SearchController.followButtonHandler),
                                    forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    
    
    func followButtonHandler(sender:UIButton!) {
    
        let realm = AppDelegate.realm
        
        let friendId : String = self.users[sender.tag].uid
        let userID : String! = AppDelegate.currentUser.uid
        
        if sender.titleLabel?.text == "follow" {
            
            let update = ["/users/\(userID)/following/\(friendId)/": true,
                          "/users/\(friendId)/friends/\(userID)/": true]
            ref.updateChildValues(update)
            
            let user = UserModel()
            user.load(self.users[sender.tag])
            
            try! realm.write {
                realm.add(user, update: true)
            }
            
            print("followed " + user.name)
            
        } else {
            
            let update = ["/users/\(userID)/following/\(friendId)/": false,
                          "/users/\(friendId)/friends/\(userID)/": false]
            ref.updateChildValues(update)
            
            let user = UserModel()
            user.load(self.users[sender.tag])
            user.follow = false
            
            let predicate = NSPredicate(format: "uid = %@", friendId)
            let clips = realm.objects(ClipModel.self).filter(predicate)
            
            try! realm.write {
                realm.add(user, update: true)
                clips.setValue(false, forKeyPath: "follow")
            }
            
            print("unfollowed " + user.name)
            
        }
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : User) -> Bool in
            let categoryMatch = scope == "All"
            return categoryMatch && user.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
}

extension SearchController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
