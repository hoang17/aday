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

class SearchController: UITableViewController {
    
    var users = [User]()
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let following = AppDelegate.currentUser.following
        
        for uid in following.keys {
            
            self.ref.child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let user = User(snapshot: snapshot)
                self.users.append(user)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.users.indexOf(user)!, inSection: 0)], withRowAnimation: .Automatic)
            })
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
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
        
        let following = AppDelegate.currentUser.following
        if following[user.uid] != nil && following[user.uid] == true {
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
    
        let friendId : String = self.users[sender.tag].uid
        let userID : String! = AppDelegate.uid
        
        let realm = AppDelegate.realm
        
        if sender.titleLabel?.text == "follow" {
            
            let user = realm.objectForPrimaryKey(UserModel.self, key: friendId)!
            let clips = realm.objects(ClipModel.self).filter("uid = '\(friendId)'")
            
            try! realm.write {
                AppDelegate.currentUser.following[friendId] = true
                user.follow = true
                clips.setValue(true, forKeyPath: "follow")
            }
            
            let update:[String:AnyObject] = ["/users/\(userID)/following/\(friendId)/": true,
                                             "/users/\(friendId)/friends/\(userID)/": true]
            ref.updateChildValues(update)
            
            print("followed " + self.users[sender.tag].name)
            
        } else {
            
            let user = realm.objectForPrimaryKey(UserModel.self, key: friendId)!
            let clips = realm.objects(ClipModel.self).filter("uid = '\(friendId)'")
            
            try! realm.write {
                AppDelegate.currentUser.following[friendId] = false
                user.follow = false
                clips.setValue(false, forKeyPath: "follow")
            }
            
            let update:[String:AnyObject] = ["/users/\(userID)/following/\(friendId)/": false,
                                             "/users/\(friendId)/friends/\(userID)/": false]
            ref.updateChildValues(update)
            
            print("unfollowed " + self.users[sender.tag].name)
        }
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : User) -> Bool in
            let categoryMatch = scope == "All"
            return categoryMatch && user.name.lowercaseString.containsString(searchText.lowercaseString)
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
