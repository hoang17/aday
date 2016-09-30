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

class SearchController: UITableViewController {
    // MARK: - Properties
//    var detailViewController: DetailViewController? = nil
    var users = [User]()
    var filteredUsers = [User]()
    var userkeys = [String:User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        let ref = FIRDatabase.database().reference()
        
//        ref.child("users").observeEventType(.Value, withBlock: { snapshot in
//            print("...returning users...")
//            for item in snapshot.children {
//                let user = User(snapshot: item as! FIRDataSnapshot)
//                self.users.append(user)
//                
//                
//            }
//            self.tableView.reloadData()
//        })
        
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
                    
                    ref.child("users").queryOrderedByChild("fb").queryEqualToValue(fb).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        let user = User(snapshot: snapshot.children.allObjects.first as! FIRDataSnapshot)
                        if self.userkeys[user.uid] == nil{
                            self.users.append(user)
                            self.userkeys[user.uid] = user
                            self.tableView.reloadData()
                        }
                        
                    }) { (error) in
                        print(error)
                    }
                    
                }
                print("Found \(self.users.count) friends")
            } else {
                print("Error Getting Friends \(error)");
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
//                        var number = phone.number!.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
                        var number = phone.number!.removeWhitespace()
                        if number.hasPrefix("0"){
                            number = "+84" + String(number.characters.dropFirst())
                        }
                        
                        if AppDelegate.currentUser != nil && number == AppDelegate.currentUser.phone {
                            continue
                        }
                        
                        ref.child("users").queryOrderedByChild("phone").queryEqualToValue(number).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let snap = snapshot.children.allObjects.first as? FIRDataSnapshot {
                                let user = User(snapshot: snap)
                                if user.uid != AppDelegate.currentUser.uid {
                                    if self.userkeys[user.uid] == nil{
                                        self.users.append(user)
                                        self.userkeys[user.uid] = user
                                        self.tableView.reloadData()
                                    }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let user: User
        if searchController.active && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.textLabel!.text = user.name
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : User) -> Bool in
            let categoryMatch = scope == "All"
            return categoryMatch && user.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }

}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
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