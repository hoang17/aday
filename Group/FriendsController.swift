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

    var friends: Results<UserModel>!
    
    var myGroup = DispatchGroup()
    
    var notificationToken: NotificationToken? = nil
    
    var alerted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Pinly"
        
        navigationController?.hidesBarsOnSwipe = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(findFriends))
        
        let realm = AppDelegate.realm

        friends = realm?.objects(UserModel.self).filter("following = true AND uploaded > \(AppDelegate.startdate)").sorted(byProperty: "uploaded", ascending: false)
        
        notificationToken = friends.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard (self?.tableView) != nil else { return }
            switch changes {
            case .initial:
                // tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("update friends tableview")
                self!.tableView.beginUpdates()
                self!.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                    with: .automatic)
                self!.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                    with: .automatic)
                self!.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                    with: .automatic)
                self!.tableView.endUpdates()
                break
            case .error(let error):
                print(error)
                break
            }
        }
    
        view.backgroundColor = .white
        
        // Setup friends table
        
        tableView.rowHeight = 345
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        //tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.separatorStyle = .none        
    }
    
    func findFriends() {
        let navigationController = UINavigationController(rootViewController: SyncContactController(count: friends.count))
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !alerted {
            if friends.count == 0 || (friends.count == 1 && friends[0].uid == AppDelegate.uid) {
                alerted = true
                findFriends()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = friends[indexPath.row]
        let cell = TableViewCell(friendUid: friend.uid)
        cell.controller = self
        cell.nameLabel.text = friend.name
        cell.locationLabel.text = friend.city + " · " + friend.country
        cell.profileImg.contentMode = .scaleAspectFit
        cell.profileImg.kf.setImage(with: URL(string: "https://graph.facebook.com/\(friends[indexPath.row].fb)/picture?type=large&return_ssl_resources=1"))
        cell.friendName = friend.name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMore))
        cell.moreButton.addGestureRecognizer(tap)
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tapMore(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: self.tableView)
        let indexPath : IndexPath = self.tableView.indexPathForRow(at: tapLocation)!
        let friend = self.friends[indexPath.row]
        let userID : String! = AppDelegate.uid
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
//        let friendName = friend.name
//        let c = AppDelegate.realm.objects(ClipModel.self).filter("uid = '\(friend.uid)' AND trash = false").sorted("date", ascending: false).first!
//        let clip = Clip(data: c)

        // Create the action sheet
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive) { [weak self] (action) in
            
            FriendsLoader.sharedInstance.report(friend.uid)
            
            let alert = UIAlertController(title: "You have reported\n" + friend.name, message: "Thank you for your reporting. Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
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
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.default) { (action) in
            FriendsLoader.sharedInstance.unfollow(friend.uid)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            // print("Cancel action button tapped")
        }
        
        if userID != friend.uid{
            myActionSheet.addAction(reportAction)
        }
        
//        myActionSheet.addAction(shareAction)
//        myActionSheet.addAction(shareFBAction)
//        myActionSheet.addAction(shareIGAction)
        
        myActionSheet.addAction(unfollowAction)
        myActionSheet.addAction(cancelAction)
        
//        // support iPads (popover view)
//        myActionSheet.popoverPresentationController?.sourceView = self.showActionSheetButton
//        myActionSheet.popoverPresentationController?.sourceRect = self.showActionSheetButton.bounds
        
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]) {
        print("sharer didCompleteWithResults")
        print(results)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("sharer didFailWithError")
        print(error)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    
    func shareButton(_ inputURl: URL) {
        
        let objectsToShare = [inputURl]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.setValue("Video", forKey: "subject")
        
        //New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks,  UIActivityType.print]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.print ]
        }

        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
}
