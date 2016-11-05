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

class CameraPlaybackController: UIViewController, FBSDKSharingDelegate {

    var textField = PinTextLabel()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var clips: Results<ClipModel>!
    var playIndex = 0
    var player: ClipPlayer!
    
    var nextplayer: ClipPlayer! // cache for smooth
    var prevplayer: ClipPlayer! // cache for smooth
    
    var commentsButton = UIButton()
    var commentBox = CommentTextView()
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
        
        navigationController?.isNavigationBarHidden = true
        
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField.textColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.textAlignment = NSTextAlignment.center
        textField.height = 34
        textField.width = UIScreen.main.bounds.width
        textField.isUserInteractionEnabled = false
        textField.center.y = self.view.height * CGFloat(clips[playIndex].y)
        
        if textField.text == "" {
            textField.isHidden = true
        }
        
        profileImg.origin = CGPoint(x: 15, y: 15)
        profileImg.size = CGSize(width: 30, height: 30)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.contentMode = .scaleAspectFit
        profileImg.backgroundColor = UIColor.white
        
        nameLabel.origin = CGPoint(x: 55, y: 9)
        nameLabel.height = 28
        nameLabel.textColor = UIColor.white
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
        moreLabel.textColor = UIColor.white
        moreLabel.font = UIFont(name: "OpenSans-Bold", size: 20.0)
        moreLabel.isUserInteractionEnabled = true

        commentBox.isHidden = true
        commentBox.height = 38
        commentBox.width = UIScreen.main.bounds.width
        commentBox.sendCallback = { [weak self] in
            self?.commentBox.commentField.resignFirstResponder()
            self?.commentBox.isHidden = true
            self?.player.play()
            if let cm = self?.commentBox.commentField.text {
                FriendsLoader.sharedInstance.comment(self!.clips[self!.playIndex], text: cm)
                self?.commentBox.commentField.text = ""
            }
        }
        
//        commentField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
//        commentField.textColor = UIColor.whiteColor()
//        commentField.font = UIFont.systemFontOfSize(16.0)
//        commentField.textAlignment = NSTextAlignment.Left
//        commentField.placeHolder = "Write a comment..."
//        commentField.placeHolderColor = UIColor(white: 1, alpha: 0.5)
//        
//        commentField.text = ""
//        commentField.hidden = true
//        commentField.height = 34
//        commentField.width = UIScreen.mainScreen().bounds.width
//        //commentField.returnKeyType = UIReturnKeyType.Send
//        commentField.returnKeyType = UIReturnKeyType.Default
//        commentField.userInteractionEnabled = true
        
        let commentsIcon = UIImage(named: "ic_comment") as UIImage?
        commentsButton = UIButton(type: .system)
        commentsButton.tintColor = UIColor(white: 1, alpha: 0.5)
        commentsButton.backgroundColor = UIColor.clear
        commentsButton.setImage(commentsIcon, for: UIControlState())
        commentsButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
        commentsButton.origin = CGPoint(x: 15, y: view.height-35)
        commentsButton.size = CGSize(width: 30, height: 23)
        
        view.addSubview(textField)
        view.addSubview(profileImg)
        view.addSubview(nameLabel)
        view.addSubview(locationLabel)
        view.addSubview(dateLabel)
        view.addSubview(moreLabel)
        view.addSubview(commentBox)
        view.addSubview(commentsButton)
        
        let tapmore = UITapGestureRecognizer(target: self, action: #selector(tapMore))
        moreLabel.addGestureRecognizer(tapmore)
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(swipeUp)
                
        play()
    }
    
    func showComments() {
        player.player?.pause()
        self.navigationController?.pushViewController(CommentsController(clip: clips[playIndex]), animated: true)
    }
    
    func tapMore(_ sender: UITapGestureRecognizer) {
        
        player.player?.pause()
        
        let clip = Clip(data: clips[playIndex])
        
        print(clip.id)
        
        let userID : String! = AppDelegate.uid
        
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive) { [weak self] (action) in
            
            let confirmAlert = UIAlertController(title: "Report", message: "Do you want to report this pin?", preferredStyle: UIAlertControllerStyle.alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { [weak self] (action) in
                
                let alert = UIAlertController(title: "This content has been reported\n", message: "Our moderators have been notified and we will take action imediately!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [weak self] (action) in
                    self?.close()
                    FriendsLoader.sharedInstance.reportClip(self!.clips[self!.playIndex])
                }))
                self?.present(alert, animated: true, completion: nil)
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
                self?.player.player?.play()
            }))
            
            self?.present(confirmAlert, animated: true, completion: nil)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default) { [weak self] (action) in
            
            let text = "Exporting pin..."
            self?.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self!.friendName!, profileImg: self!.profileImg.image!) { [weak self] (savePathUrl) in
                self?.removeAllOverlays()
                self?.shareClip(savePathUrl)
            }
        }

        let shareFBAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { [weak self] (action) in
            
            let text = "Exporting pin..."
            self?.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self!.friendName, profileImg: self!.profileImg.image!) { [weak self] (savePathUrl) in
                
                self?.removeAllOverlays()
                ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: savePathUrl, completionBlock: { [weak self] (assetURL, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if assetURL != nil {
                        print(assetURL)
                        DispatchQueue.main.async(execute: {
                            let video = FBSDKShareVideo(videoURL: assetURL)
                            let content = FBSDKShareVideoContent()
                            content.video = video
                            FBSDKShareDialog.show(from: self, with: content, delegate: self)
                        })
                    }
                })
            }
        }
        
        let shareIGAction = UIAlertAction(title: "Share on Instagram", style: UIAlertActionStyle.default) { [weak self] (action) in
            
            let text = "Exporting pin..."
            self?.showWaitOverlayWithText(text)
            
            VideoHelper.sharedInstance.export(clip, friendName: self!.friendName, profileImg: self!.profileImg.image!) { [weak self] (savePathUrl) in
                
                self?.removeAllOverlays()
                ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: savePathUrl, completionBlock: { (assetURL, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if assetURL != nil {
                        print(assetURL)
                        let escapedString = assetURL?.absoluteString.urlencodedString()
                        let escapedCaption = "Pinly".urlencodedString()
                        let instagramURL = URL(string: "instagram://library?AssetPath=\(escapedString)&InstagramCaption=\(escapedCaption)")!
                        UIApplication.shared.openURL(instagramURL)
                    }
                })
            }
        }
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            
            let confirmAlert = UIAlertController(title: "Delete", message: "Do you want to delete this pin?", preferredStyle: UIAlertControllerStyle.alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
                self?.close()
                FriendsLoader.sharedInstance.deleteClip(self!.clips[self!.playIndex])
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
                self?.player.player?.play()
            }))
            
            self?.present(confirmAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { [weak self] (action) in
            self?.player.player?.play()
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
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]) {
        print(results)
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print(error)
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        self.removeAllOverlays()
        player.player?.play()
    }
    
    func shareClip(_ inputURL: URL) {
        
        let objectsToShare = [inputURL]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Pin moment" , forKey: "subject") // email subject
        
        // Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks,  UIActivityType.print]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.print ]
        }
        
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        activityVC.completionWithItemsHandler = { [weak self] (activity, completed, items, error) in
            self?.removeAllOverlays()
            self?.player.player?.play()
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func tapGesture(_ sender:UITapGestureRecognizer){
        
        if commentBox.isHidden == false {
            commentBox.commentField.resignFirstResponder()
            commentBox.isHidden = true
            player.play()
            return
        }
        
        player.pause()
        
        let location = sender.location(in: self.view)
        
        if location.x > 0.25*UIScreen.main.bounds.width {
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

    func swipeUpGesture(){
        player.player?.pause()
        commentBox.isHidden = false
        commentBox.y = view.height - 34
        commentBox.commentField.becomeFirstResponder()
        view.bringSubview(toFront: commentBox)
    }
    
    func swipeDownGesture(){
        close()
    }
    
    func locationText() -> String {
        let clip = clips[playIndex]
        return clip.subarea != "" ? clip.subarea + " · " + clip.city : ""
    }
    
    func initPlayer(_ index: Int) -> ClipPlayer {
        return ClipPlayer(clip: clips[index], frame: UIScreen.main.bounds)
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
        textField.autoHeight(false)
        textField.center.y = self.view.height * CGFloat(clip.y)
        textField.isHidden = textField.text == ""
        dateLabel.text = (Date(timeIntervalSince1970: clip.date) as NSDate).shortTimeAgoSinceNow()
        
        view.addSubview(player)
        
        view.bringSubview(toFront: textField)
        view.bringSubview(toFront: profileImg)
        view.bringSubview(toFront: nameLabel)
        view.bringSubview(toFront: dateLabel)
        view.bringSubview(toFront: moreLabel)
        view.bringSubview(toFront: locationLabel)
        view.bringSubview(toFront: commentsButton)
        
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
        
        self.dismiss(animated: true, completion: nil)

        if (playIndex >= 0) && playIndex < clips.count {
            
            let indexPath = IndexPath(row: playIndex, section: 0)
            
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath,
               at: .centeredHorizontally,
               animated: false)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit {
        //print("deinit camera playback")
    }
}

