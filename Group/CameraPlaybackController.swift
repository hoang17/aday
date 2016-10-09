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

class CameraPlaybackController: UIViewController, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var clips = [ClipModel]()
    var playIndex = 0
    var player: ClipPlayer!
    
    var player1: ClipPlayer! // cache for smooth
    var player2: ClipPlayer! // cache for smooth
    
    var nextplayer: ClipPlayer! // cache for smooth
    var prevplayer: ClipPlayer! // cache for smooth
    
    var profileImg = UIImageView()
    var nameLabel = UILabel()
    var locationLabel = UILabel()
    var dateLabel = UILabel()
    var moreLabel = UILabel()
    var collectionView: UICollectionView!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(player)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object:player.player.currentItem)
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(16.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.height = 34
        textField.width = UIScreen.mainScreen().bounds.width
        textField.userInteractionEnabled = false
        textField.text = clips[playIndex].txt
        textField.center.y = self.view.height * CGFloat(clips[playIndex].y)
        
        if textField.text == "" {
            textField.hidden = true
        }
        
        profileImg.origin = CGPoint(x: 15, y: 15)
        profileImg.size = CGSize(width: 30, height: 30)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        
        nameLabel.origin = CGPoint(x: 55, y: 9)
        nameLabel.height = 28
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        locationLabel.origin = CGPoint(x: 55, y: 31)
        locationLabel.size = CGSize(width: self.view.width, height: 14)
        locationLabel.textColor = UIColor(white: 1, alpha: 0.6)
        locationLabel.font = UIFont(name: "OpenSans", size: 10.0)
        locationLabel.text = locationText()
        
        dateLabel.origin.y = nameLabel.y
        dateLabel.text = NSDate(timeIntervalSince1970: clips[playIndex].date).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: nameLabel.height)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.6)
        dateLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        moreLabel.text = "..."
        moreLabel.origin = CGPoint(x: view.width-30, y: view.height-40)
        moreLabel.size = CGSize(width: 30, height: 20)
        moreLabel.textColor = UIColor.whiteColor()
        moreLabel.font = UIFont(name: "OpenSans", size: 18.0)
        moreLabel.userInteractionEnabled = true

        view.addSubview(textField);
        view.addSubview(profileImg)
        view.addSubview(nameLabel)
        view.addSubview(locationLabel)
        view.addSubview(dateLabel)
        view.addSubview(moreLabel)
        
        let tapmore = UITapGestureRecognizer(target: self, action: #selector(tapMore))
        moreLabel.addGestureRecognizer(tapmore)
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDown)
    }
    
    func tapMore(sender: UITapGestureRecognizer) {
        
        player.player.pause()
        
        let clip = clips[playIndex]
        
        let userID : String! = AppDelegate.currentUser.uid
        
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive) { (action) in
            
            let confirmAlert = UIAlertController(title: "Report", message: "Do you want to report this pin?", preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action) in
                
                let alert = UIAlertController(title: "This content has been reported\n", message: "Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.close()
                    FriendsLoader.sharedInstance.reportClip(clip)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.player.player.play()
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
            
        }
        
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (action) in
            self.shareClip(clip)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            
            let confirmAlert = UIAlertController(title: "Delete", message: "Do you want to delete this pin?", preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
                self.close()
                FriendsLoader.sharedInstance.deleteClip(clip)
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.player.player.play()
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            self.player.player.play()
        }
        
        if userID != uid {
            myActionSheet.addAction(reportAction)
        }
        
        myActionSheet.addAction(shareAction)
        
        if userID == uid {
            myActionSheet.addAction(deleteAction)
        }
        
        myActionSheet.addAction(cancelAction)
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    func shareClip(clip: ClipModel) {
        
        let filePath = NSTemporaryDirectory() + clip.fname
        let videoLink = NSURL(fileURLWithPath: filePath)
        
        let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
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
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        
        player.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player.player.currentItem)
        
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
    
    func swipeDownGesture(){
        player.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player.player.currentItem)
        close()
    }
    
    func playerAtIndex(playIndex: Int) -> ClipPlayer? {
        
        if playIndex > 0 {
            prevplayer = ClipPlayer(clip: clips[playIndex-1], frame: UIScreen.mainScreen().bounds)
        }
        if playIndex + 1 < clips.count {
            nextplayer = ClipPlayer(clip: clips[playIndex+1], frame: UIScreen.mainScreen().bounds)
        }
        
        return ClipPlayer(clip: clips[playIndex], frame: UIScreen.mainScreen().bounds)
    }
    
    func locationText() -> String {
        let clip = clips[playIndex]
        return clip.subarea != "" ? clip.subarea + " · " + clip.city : ""
    }
    
    func playPrevClip(){
        playIndex -= 1
        
        player2 = player1
        player1 = player
        if player2 != nil {
            player2.removeFromSuperview()
        }
        
        nextplayer = player
        player = prevplayer
        play()
        
        if playIndex > 0 {
            prevplayer = ClipPlayer(clip: clips[playIndex-1], frame: UIScreen.mainScreen().bounds)
        }
    }
    
    func playNextClip(){
        playIndex += 1
        
        player2 = player1
        player1 = player
        if player2 != nil {
            player2.removeFromSuperview()
        }
        
        prevplayer = player
        player = nextplayer
        play()
        
        if playIndex + 1 < clips.count {
            nextplayer = ClipPlayer(clip: clips[playIndex+1], frame: UIScreen.mainScreen().bounds)
        }
    }
    
    func play() {
        
        locationLabel.text = locationText()
        textField.text = clips[playIndex].txt
        textField.center.y = self.view.height * CGFloat(clips[playIndex].y)
        textField.hidden = textField.text == ""
        dateLabel.text = NSDate(timeIntervalSince1970: clips[playIndex].date).shortTimeAgoSinceNow()
        
        view.addSubview(player)
        
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        view.bringSubviewToFront(moreLabel)
        view.bringSubviewToFront(locationLabel)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.player.currentItem)
    }

    func playerDidFinishPlaying(notification: NSNotification) {
        if clips.count > playIndex + 1 {
            playNextClip()
        } else {
            close()
        }
    }
    
    func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: playIndex, inSection: 0) , atScrollPosition: .CenteredHorizontally, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

