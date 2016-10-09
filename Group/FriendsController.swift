//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import Contacts
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RealmSwift
import Kingfisher
import AVFoundation
import FBSDKShareKit
import Social
import AssetsLibrary

class FriendsController: UITableViewController, FBSDKSharingDelegate {
    
//    var friends = [User]()
    
    var friends: Results<UserModel>!
    
    var myGroup = dispatch_group_create()
    
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = AppDelegate.realm
        
        let ref = FIRDatabase.database().reference()
        
        let userID : String! = FIRAuth.auth()?.currentUser?.uid
        
        let today = NSDate()
        let dayago = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Day,
                value: -30,
                toDate: today,
                options: []
        )
        let d : Double = (dayago?.timeIntervalSince1970)!
        
        friends = realm.objects(UserModel.self).filter("follow = true AND uploaded > \(d)").sorted("uploaded", ascending: false)
        
        notificationToken = friends.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard (self?.tableView) != nil else { return }
            switch changes {
            case .Initial:
                // tableView.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
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
    
        view.backgroundColor = .whiteColor()
        
        // Setup friends table
        
        tableView.rowHeight = 345
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        tableView.separatorStyle = .None
        
        print("loading friends for \(userID)...")
        
        ref.child("users").queryOrderedByChild("friends/\(userID)").queryEqualToValue(true).observeEventType(.Value, withBlock: { snapshot in
            
            for item in snapshot.children {
                
                let friend = User(snapshot: item as! FIRDataSnapshot)
                self.downloadClips(friend.clips)
                
                let data = UserModel(user: friend)
                try! realm.write {
                    realm.add(data, update: true)
                }
            }
            
            print("loaded \(snapshot.children.allObjects.count) friends")
            
        })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = TableViewCell()
        cell.controller = self
        cell.nameLabel.text = friends[indexPath.row].name
        cell.locationLabel.text = friends[indexPath.row].city + " · " + friends[indexPath.row].country
        cell.profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
        cell.clips = Array(friends[indexPath.row].clips)
        cell.friend = friends[indexPath.row]
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMore))
        cell.moreButton.addGestureRecognizer(tap)
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tapMore(sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.locationInView(self.tableView)
        let indexPath : NSIndexPath = self.tableView.indexPathForRowAtPoint(tapLocation)!
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        let friend = self.friends[indexPath.row]
        let userID : String! = AppDelegate.currentUser.uid

        VideoHelper.sharedInstance.export(friend.clips.first!, friend: friend, profileImg: cell.profileImg.image!)
        
        // Create the action sheet
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive) { (action) in
            
            FriendsLoader.sharedInstance.report(friend.uid)
            
            let alert = UIAlertController(title: "You have reported\n" + friend.name, message: "Thank you for your reporting. Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (action) in
            self.shareButton(friend)
        }
        
        let shareFBAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) in
            
            let filePath = NSTemporaryDirectory() + "exp_" + friend.clips.first!.fname
            let inputURL = NSURL(fileURLWithPath: filePath)
            
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(inputURL, completionBlock: { (assetURL, error) in
                if error != nil {
                    print(error)
                    return
                }
                if let assurl = assetURL {
                    print(assetURL)
                    let video = FBSDKShareVideo(videoURL: assetURL)
                    let content = FBSDKShareVideoContent()
                    content.video = video
                    
                    FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
                    
//                    let dialog = FBSDKShareDialog()
//                    dialog.fromViewController = self
//                    dialog.delegate = self
//                    dialog.shareContent = content
//                    dialog.mode = .ShareSheet
//                    dialog.show()
                    
//                    var shareToFacebook: SLComposeViewController = SLComposeViewController(forServiceType:  SLServiceTypeFacebook)
//                    shareToFacebook.setInitialText("Check out this beat! From the DropABeat App")
//                    self.presentViewController(shareToFacebook, animated: true, completion: nil)
                }
            })
        }
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Default) { (action) in
            FriendsLoader.sharedInstance.unfollow(friend.uid)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            // print("Cancel action button tapped")
        }
        
        if userID != friend.uid{
            myActionSheet.addAction(reportAction)
        }
        
        myActionSheet.addAction(shareAction)
        myActionSheet.addAction(shareFBAction)
        
        if userID != friend.uid{
            myActionSheet.addAction(unfollowAction)
        }
        
        myActionSheet.addAction(cancelAction)
        
//        // support iPads (popover view)
//        myActionSheet.popoverPresentationController?.sourceView = self.showActionSheetButton
//        myActionSheet.popoverPresentationController?.sourceRect = self.showActionSheetButton.bounds
        
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject: AnyObject]) {
        print("sharer didCompleteWithResults")
        print(results)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("sharer didFailWithError")
        print(error)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    
    func shareButton(friend: UserModel) {
        
        let filePath = NSTemporaryDirectory() + friend.clips.first!.fname
        let videoLink = NSURL(fileURLWithPath: filePath)
        
        let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.setValue("Video", forKey: "subject")
        
        //New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks,  UIActivityTypePrint]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypePrint ]
        }
        
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.presentViewController(activityVC, animated: true, completion: nil)
 
//        // image to share
//        let image = UIImage(named: "Image")
//        
//        let objectsToShare: [AnyObject] = [ image! ]
//        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        
//        // exclude some activity types from the list (optional)
//        // activityViewController.excludedActivityTypes = [ UIActivityTypeAirDrop, UIActivityTypePostToFacebook ]
//        
//        // present the view controller
//        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func downloadClips(clips: [Clip]){
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        for clip in clips {
            
            let fileName = clip.fname
            
            // Check if file not existed then download
            let filePath = NSTemporaryDirectory() + fileName;
            if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                
                print("Downloading file \(fileName)...")
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
}
