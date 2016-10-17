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
                
        friends = realm.objects(UserModel.self).filter("follow = true").sorted("uploaded", ascending: false)
        
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
    
        view.backgroundColor = .whiteColor()
        
        // Setup friends table
        
        tableView.rowHeight = 345
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        tableView.separatorStyle = .None        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend = friends[indexPath.row]
        let cell = TableViewCell(friendUid: friend.uid)
        cell.controller = self
        cell.nameLabel.text = friend.name
        cell.locationLabel.text = friend.city + " · " + friend.country
        cell.profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
        cell.friendName = friend.name
        
        // cell.friendUid = friend.uid
        // cell.clips = Array(friend.clips)
        
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
        let friend = self.friends[indexPath.row]
        let userID : String! = AppDelegate.uid
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
//        let friendName = friend.name
//        let c = AppDelegate.realm.objects(ClipModel.self).filter("uid = '\(friend.uid)' AND trash = false").sorted("date", ascending: false).first!
//        let clip = Clip(data: c)
        // let clip = Clip(data: friend.clips.first!)

        // Create the action sheet
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive) { (action) in
            
            FriendsLoader.sharedInstance.report(friend.uid)
            
            let alert = UIAlertController(title: "You have reported\n" + friend.name, message: "Thank you for your reporting. Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
//        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (action) in
//            let text = "Exporting pin..."
//            self.showWaitOverlayWithText(text)
//            
//            VideoHelper.sharedInstance.export(clip, friendName: friendName, profileImg: cell.profileImg.image!) { (savePathUrl) in
//                self.removeAllOverlays()
//                self.shareButton(savePathUrl)
//            }
//        }
//        
//        let shareFBAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) in
//
//            let text = "Exporting pin..."
//            self.showWaitOverlayWithText(text)
//
//            VideoHelper.sharedInstance.export(clip, friendName: friendName, profileImg: cell.profileImg.image!){ (savePathUrl) in
//                
//                self.removeAllOverlays()
//                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL, error) in
//                    if error != nil {
//                        print(error)
//                        return
//                    }
//                    if assetURL != nil {
//                        print(assetURL)
//                        dispatch_async(dispatch_get_main_queue(), {
//                            let video = FBSDKShareVideo(videoURL: assetURL)
//                            let content = FBSDKShareVideoContent()
//                            content.video = video
//                            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
//                        })
//                    }
//                })
//            }            
//        }
//        
//        let shareIGAction = UIAlertAction(title: "Share on Instagram", style: UIAlertActionStyle.Default) { (action) in
//            
//            let text = "Exporting pin..."
//            self.showWaitOverlayWithText(text)
//            
//            VideoHelper.sharedInstance.export(clip, friendName: friendName, profileImg: cell.profileImg.image!){ (savePathUrl) in
//                
//                self.removeAllOverlays()
//                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL, error) in
//                    if error != nil {
//                        print(error)
//                        return
//                    }
//                    if assetURL != nil {
//                        print(assetURL)
//                        let escapedString = assetURL.absoluteString!.urlencodedString()
//                        let escapedCaption = "Pinly".urlencodedString()
//                        let instagramURL = NSURL(string: "instagram://library?AssetPath=\(escapedString)&InstagramCaption=\(escapedCaption)")!
//                        UIApplication.sharedApplication().openURL(instagramURL)
//                    }
//                })
//            }
//        }
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Default) { (action) in
            FriendsLoader.sharedInstance.unfollow(friend.uid)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            // print("Cancel action button tapped")
        }
        
        if userID != friend.uid{
            myActionSheet.addAction(reportAction)
        }
        
//        myActionSheet.addAction(shareAction)
//        myActionSheet.addAction(shareFBAction)
//        myActionSheet.addAction(shareIGAction)
        
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
    
    func shareButton(inputURl: NSURL) {
        
        let objectsToShare = [inputURl]
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
}
