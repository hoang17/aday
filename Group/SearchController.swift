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
    
    var friends = [Friend]()
    var friendKeys = [String:Friend]()
    var filteredFriends = [Friend]()
    let searchController = UISearchController(searchResultsController: nil)
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref.child("friends/\(AppDelegate.uid)").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            let friend = Friend(snapshot: snapshot)
            
            self.ref.child("users").child(friend.fuid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let user = User(snapshot: snapshot)
                friend.load(user)
                self.friends.append(friend)
                self.friendKeys[friend.fuid] = friend
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.friends.indexOf(friend)!, inSection: 0)], withRowAnimation: .Automatic)
            })
        })

        ref.child("friends/\(AppDelegate.uid)").observeEventType(.ChildChanged, withBlock: { snapshot in
            let friend = Friend(snapshot: snapshot)
            let t = self.friendKeys[friend.fuid]
            friend.fb = t!.fb
            friend.name = t!.name
            friend.city = t!.city
            friend.country = t!.country
            friend.uploaded = t!.uploaded
            
            let index = self.friends.indexOf(self.friendKeys[friend.fuid]!)
            self.friendKeys[friend.fuid] = friend
            self.friends[index!] = friend
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Automatic)
        })
        
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
            return filteredFriends.count
        }
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = SearchItemCell()
        var friend: Friend
        if searchController.active && searchController.searchBar.text != "" {
            friend = filteredFriends[indexPath.row]
        } else {
            friend = friends[indexPath.row]
        }
        
        // Set cell data
        cell.nameLabel.text = friend.name
        
        let imgUrl = NSURL(string: "https://graph.facebook.com/\(friend.fb)/picture?type=large&return_ssl_resources=1")
        cell.profileImg.kf_setImageWithURL(imgUrl)
        
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
        let friendId = friend.fuid
        let userID : String! = AppDelegate.uid
        
        let realm = AppDelegate.realm
        
        if sender.titleLabel?.text == "follow" {
            friend.following = true
            print("followed " + self.friends[sender.tag].name)
            
        } else {
            friend.following = false
            print("unfollowed " + self.friends[sender.tag].name)
        }

        let user = realm.objectForPrimaryKey(UserModel.self, key: friendId)!
        let clips = realm.objects(ClipModel.self).filter("uid = '\(friendId)'")
        
        try! realm.write {
            user.follow = friend.following
            clips.setValue(friend.following, forKeyPath: "follow")
        }
        
        let update:[String:AnyObject] = ["/friends/\(userID)/\(friendId)/following": friend.following]
        ref.updateChildValues(update)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredFriends = friends.filter({( friend : Friend) -> Bool in
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
