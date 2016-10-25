//
//  SearchController.swift
//  Group
//
//  Created by Hoang Le on 9/20/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import APAddressBook
import DigitsKit
import RealmSwift

class SearchController: UITableViewController {
    
    var friends: Results<UserModel>!
    var filteredFriends = [UserModel]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Explore"

        //navigationController?.hidesBarsOnSwipe = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(findFriends))
        
        let realm = AppDelegate.realm
        
        friends = realm.objects(UserModel.self)
        
        notificationToken = friends.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard (self?.tableView) != nil else { return }
            switch changes {
            case .Initial:
                // tableView.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
                print("update friends tableview")
                self!.tableView.beginUpdates()
                self!.tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
                    withRowAnimation: .Automatic)
                self!.tableView.endUpdates()
                break
            case .Error(let error):
                print(error)
                break
            }
        }
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("friends/\(AppDelegate.uid)").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            let friend = Friend(snapshot: snapshot)
            
            ref.child("users").child(friend.fuid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let data = User(snapshot: snapshot)
                
                let user = UserModel(user: data)
                user.following = friend.following
                
                try! realm.write {
                    realm.add(user, update: true)
                }
                print("friend added \(user.name)")
            })
        })

        ref.child("friends/\(AppDelegate.uid)").observeEventType(.ChildChanged, withBlock: { snapshot in
            
            let friend = Friend(snapshot: snapshot)
            
            ref.child("users").child(friend.fuid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let data = User(snapshot: snapshot)
                
                let user = UserModel(user: data)
                user.following = friend.following
                
                try! realm.write {
                    realm.add(user, update: true)
                }
                print("friend updated \(user.name)")
            })            
        })
        
        //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for friends"
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func findFriends() {
        let navigationController = UINavigationController(rootViewController: SyncContactController(count: friends.count))
        navigationController.view.backgroundColor = UIColor.clearColor()
        navigationController.modalPresentationStyle = .OverFullScreen
        presentViewController(navigationController, animated: true, completion: nil)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredFriends.count
        }
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var friend: UserModel
        if searchController.active && searchController.searchBar.text != "" {
            friend = filteredFriends[indexPath.row]
        } else {
            friend = friends[indexPath.row]
        }
        
        // Set cell data
        let cell = SearchItemCell(user: friend)
        if friend.following {
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
    
        let friend = self.friends[sender.tag]
        let friendId = friend.uid
        let userID : String! = AppDelegate.uid
        
        let realm = AppDelegate.realm
        
        try! realm.write {
            friend.following = sender.titleLabel?.text == "follow"
        }
        
        let ref = FIRDatabase.database().reference()
        let update:[String:AnyObject] = ["/friends/\(userID)/\(friendId)/following": friend.following]
        ref.updateChildValues(update)
        
        if friend.following {
            print("followed " + self.friends[sender.tag].name)
        } else {
            print("unfollowed " + self.friends[sender.tag].name)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredFriends = friends.filter({( friend : UserModel) -> Bool in
            let categoryMatch = scope == "All"
            return categoryMatch && friend.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchController: UISearchResultsUpdating {

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
