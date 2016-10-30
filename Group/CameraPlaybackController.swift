//
//  CameraPreviewController.swift
//  Group
//
//  Created by Hoang Le on 9/7/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVKit
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import DigitsKit
import DateTools
import FBSDKShareKit
import AssetsLibrary
import RealmSwift
import Kingfisher
import DGActivityIndicatorView
import SwiftOverlays
//import MRProgress

class CameraPlaybackController: UIViewController, UITextFieldDelegate, FBSDKSharingDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var clips: Results<ClipModel>!
    var playIndex = 0
    var player: ClipPlayer!
    
    var nextplayer: ClipPlayer! // cache for smooth
    var prevplayer: ClipPlayer! // cache for smooth
    
    var commentsButton = UIButton()
    let commentField = UITextField()
    var profileImg = UIImageView()
    var nameLabel = UILabel()
    var locationLabel = UILabel()
    var dateLabel = UILabel()
    var moreLabel = UILabel()
    var collectionView: UICollectionView!
    var friendName: String!
    var friendUid: String!
    
    convenience init(playIndex: Int, clips: Results<ClipModel>){
        self.init()
        self.clips = clips
        self.playIndex = playIndex
        
        if playIndex > 0 {
            prevplayer = initPlayer(playIndex-1)
        }
        if playIndex + 1 < clips.count {
            nextplayer = initPlayer(playIndex+1)
        }
        
        self.player = initPlayer(playIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(16.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.height = 34
        textField.width = UIScreen.mainScreen().bounds.width
        textField.userInteractionEnabled = false
        textField.center.y = self.view.height * CGFloat(clips[playIndex].y)
        
        if textField.text == "" {
            textField.hidden = true
        }
        
        profileImg.origin = CGPoint(x: 15, y: 15)
        profileImg.size = CGSize(width: 30, height: 30)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.contentMode = .ScaleAspectFit
        profileImg.backgroundColor = UIColor.whiteColor()
        
        nameLabel.origin = CGPoint(x: 55, y: 9)
        nameLabel.height = 28
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        locationLabel.origin = CGPoint(x: 55, y: 31)
        locationLabel.size = CGSize(width: self.view.width, height: 14)
        locationLabel.textColor = UIColor(white: 1, alpha: 0.6)
        locationLabel.font = UIFont(name: "OpenSans", size: 10.0)
        
        dateLabel.origin.y = nameLabel.y
        dateLabel.size = CGSize(width: 50, height: nameLabel.height)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.6)
        dateLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        moreLabel.text = "..."
        moreLabel.origin = CGPoint(x: view.width-35, y: view.height-50)
        moreLabel.size = CGSize(width: 50, height: 50)
        moreLabel.textColor = UIColor.whiteColor()
        moreLabel.font = UIFont(name: "OpenSans-Bold", size: 20.0)
        moreLabel.userInteractionEnabled = true

        commentField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        commentField.textColor = UIColor.whiteColor()
        commentField.font = UIFont.systemFontOfSize(16.0)
        commentField.textAlignment = NSTextAlignment.Left
        commentField.attributedPlaceholder = NSAttributedString(string:"Write a comment...", attributes:[
                                                                    NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),
                                                                    NSFontAttributeName:UIFont.systemFontOfSize(16.0)])
        commentField.text = ""
        commentField.hidden = true
        commentField.height = 34
        commentField.width = UIScreen.mainScreen().bounds.width
        commentField.delegate = self
        commentField.returnKeyType = UIReturnKeyType.Send
        commentField.userInteractionEnabled = true
        
        let commentsIcon = UIImage(named: "ic_comment") as UIImage?
        commentsButton = UIButton(type: .System)
        commentsButton.tintColor = UIColor(white: 1, alpha: 0.5)
        commentsButton.backgroundColor = UIColor.clearColor()
        commentsButton.setImage(commentsIcon, forState: .Normal)
        commentsButton.addTarget(self, action: #selector(showComments), forControlEvents: .TouchUpInside)
        commentsButton.origin = CGPoint(x: 15, y: view.height-35)
        commentsButton.size = CGSize(width: 30, height: 23)
        
        view.addSubview(textField)
        view.addSubview(profileImg)
        view.addSubview(nameLabel)
        view.addSubview(locationLabel)
        view.addSubview(dateLabel)
        view.addSubview(moreLabel)
        view.addSubview(commentField)
        view.addSubview(commentsButton)
        
        let tapmore = UITapGestureRecognizer(target: self, action: #selector(tapMore))
        moreLabel.addGestureRecognizer(tapmore)
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(swipeUp)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        play()
    }
    
    func showComments() {
        player.player?.pause()
        self.navigationController?.pushViewController(CommentsController(clip: clips[playIndex]), animated: true)
    }
    
    func tapMore(sender: UITapGestureRecognizer) {
        
        player.player?.pause()
        
        let clip = Clip(data: clips[playIndex])
        
        print(clip.id)
        
        let userID : String! = AppDelegate.uid
        
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive) { (action) in
            
            let confirmAlert = UIAlertController(title: "Report", message: "Do you want to report this pin?", preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action) in
                
                let alert = UIAlertController(title: "This content has been reported\n", message: "Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.close()
                    FriendsLoader.sharedInstance.reportClip(self.clips[self.playIndex])
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.player.player?.play()
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (action) in
            
            let text = "Exporting pin..."
            self.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self.friendName, profileImg: self.profileImg.image!) { (savePathUrl) in
                self.removeAllOverlays()
                self.shareClip(savePathUrl)
            }
        }

        let shareFBAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) in
            
            let text = "Exporting pin..."
            self.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self.friendName, profileImg: self.profileImg.image!) { (savePathUrl) in
                
                self.removeAllOverlays()
                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if assetURL != nil {
                        print(assetURL)
                        dispatch_async(dispatch_get_main_queue(), {
                            let video = FBSDKShareVideo(videoURL: assetURL)
                            let content = FBSDKShareVideoContent()
                            content.video = video
                            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
                        })
                    }
                })
            }
        }
        
        let shareIGAction = UIAlertAction(title: "Share on Instagram", style: UIAlertActionStyle.Default) { (action) in
            
            let text = "Exporting pin..."
            self.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self.friendName, profileImg: self.profileImg.image!) { (savePathUrl) in
                
                self.removeAllOverlays()
                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if assetURL != nil {
                        print(assetURL)
                        let escapedString = assetURL.absoluteString!.urlencodedString()
                        let escapedCaption = "Pinly".urlencodedString()
                        let instagramURL = NSURL(string: "instagram://library?AssetPath=\(escapedString)&InstagramCaption=\(escapedCaption)")!
                        UIApplication.sharedApplication().openURL(instagramURL)
                    }
                })
            }
        }
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            
            let confirmAlert = UIAlertController(title: "Delete", message: "Do you want to delete this pin?", preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
                self.close()
                FriendsLoader.sharedInstance.deleteClip(self.clips[self.playIndex])
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.player.player?.play()
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            self.player.player?.play()
        }
        
        myActionSheet.addAction(shareAction)
        myActionSheet.addAction(shareFBAction)
        myActionSheet.addAction(shareIGAction)
        
        if userID != friendUid {
            myActionSheet.addAction(reportAction)
        }
        
        if userID == friendUid || userID == "lmaT7NgrkxU48Stx44JfABb6YKC2" {
            myActionSheet.addAction(deleteAction)
        }
        
        myActionSheet.addAction(cancelAction)
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject: AnyObject]) {
        print(results)
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error)
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func shareClip(inputURL: NSURL) {
        
        let objectsToShare = [inputURL]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Pin moment" , forKey: "subject") // email subject
        
        // Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks,  UIActivityTypePrint]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypePrint ]
        }
        
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityVC.completionWithItemsHandler = { (activity, completed, items, error) in
            self.removeAllOverlays()
            self.player.player?.play()
        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        
        if commentField.hidden == false {
            commentField.resignFirstResponder()
            commentField.hidden = true
            player.play()
            return
        }
        
        player.pause()
        
        let location = sender.locationInView(self.view)
        
        if location.x > 0.25*UIScreen.mainScreen().bounds.width {
            if clips.count > playIndex + 1 {
                playNextClip()
            } else {
                close()
            }
        } else {
            if playIndex > 0 {
                playPrevClip()
            } else {
                close()
            }
        }
    }

    // Move textfield ontop of keyboard
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animateWithDuration(duration, animations: {
                self.commentField.origin.y = self.view.height - keyboardSize.height - self.commentField.height
            })
            
        }
    }
    
    // On return done editing
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        commentField.hidden = true
        player.play()
        if commentField.text != "" {
            FriendsLoader.sharedInstance.comment(clips[playIndex], text: commentField.text!)
            commentField.text = ""
        }
        return true
    }
    
    func swipeUpGesture(){
        player.player?.pause()
        commentField.hidden = false
        commentField.y = view.height - 34
        commentField.becomeFirstResponder()
        view.bringSubviewToFront(commentField)
    }
    
    func swipeDownGesture(){
        close()
    }
    
    func locationText() -> String {
        let clip = clips[playIndex]
        return clip.subarea != "" ? clip.subarea + " · " + clip.city : ""
    }
    
    func initPlayer(index: Int) -> ClipPlayer {
        return ClipPlayer(clip: clips[index], frame: UIScreen.mainScreen().bounds)
    }
    
    func playPrevClip(){
        playIndex -= 1
        
        let tmp = nextplayer
        
        nextplayer = player
        player = prevplayer
        play()
        
        if playIndex > 0 {
            prevplayer = initPlayer(playIndex-1)
        }
        
        tmp?.removeFromSuperview()
    }
    
    func playNextClip(){
        playIndex += 1
        
        let tmp = prevplayer
        
        prevplayer = player
        player = nextplayer
        play()
        
        if playIndex + 1 < clips.count {
            nextplayer = initPlayer(playIndex+1)
        }
        
        tmp?.removeFromSuperview()
    }
        
    func play(){
        let clip = clips[playIndex]
        locationLabel.text = locationText()
        textField.text = clip.txt
        textField.center.y = self.view.height * CGFloat(clip.y)
        textField.hidden = textField.text == ""
        dateLabel.text = NSDate(timeIntervalSince1970: clip.date).shortTimeAgoSinceNow()
        
        view.addSubview(player)
        
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        view.bringSubviewToFront(moreLabel)
        view.bringSubviewToFront(locationLabel)
        view.bringSubviewToFront(commentsButton)
        
        player.play() {
            if self.clips.count > self.playIndex + 1 {
                self.playNextClip()
            } else {
                self.close()
            }
        }
    }

    func close(){
        player?.pause()
        
        player = nil
        nextplayer = nil
        prevplayer = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)

        if (playIndex >= 0) && playIndex < clips.count {
            
            let indexPath = NSIndexPath(forRow: playIndex, inSection: 0)
            
            collectionView.reloadItemsAtIndexPaths([indexPath])
            collectionView.scrollToItemAtIndexPath(indexPath,
               atScrollPosition: .CenteredHorizontally,
               animated: false)
            
            clips = nil
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

