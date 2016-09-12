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
import RealmSwift

class ClipPlayer: NSObject {
    var clip: Clip
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    
    init(clip: Clip, frame: CGRect) {
        self.clip = clip
//        let outputPath = NSTemporaryDirectory() + clip.fname
//        let fileUrl = NSURL(fileURLWithPath: outputPath)
        player = clip.player!.player
        playerLayer = clip.player!.playerLayer
        playerLayer.frame = frame
    }
    
    func play(){
        player.seekToTime(kCMTimeZero)
        player.play()
    }
    
    func pause(){
        player.pause()
        player.seekToTime(kCMTimeZero)
    }
}

class CameraPlaybackController: UIViewController, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var clips = [Clip]()
    var playIndex = 0
    
    var player: ClipPlayer!
//    var nextPlayer: ClipPlayer!
//    var prevPlayer: ClipPlayer!
    
    var profileImg = UIImageView()
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var friend: User!
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = ClipPlayer(clip: clips[playIndex], frame: self.view.bounds)
        
        view.layer.addSublayer(player.playerLayer)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object:player.player.currentItem)
        
//        // Cache next clip
//        if clips.count > playIndex + 1 {
//            nextPlayer = ClipPlayer(clip: clips[playIndex+1], frame: self.view.bounds)
//        }
//
//        // Cache prev clip
//        if playIndex > 0 {
//            prevPlayer = ClipPlayer(clip: clips[playIndex-1], frame: self.view.bounds)
//        }
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(16.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.height = 34
        textField.width = UIScreen.mainScreen().bounds.width
        textField.userInteractionEnabled = false
        textField.text = clips[playIndex].txt
        textField.center.y = self.view.height * clips[playIndex].y
        
        if textField.text == "" {
            textField.hidden = true
        }
        
        profileImg.origin = CGPoint(x: 20, y: 17)
        profileImg.size = CGSize(width: 30, height: 30)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        
        nameLabel.origin = CGPoint(x: 60, y: profileImg.y)
        nameLabel.height = 28
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        dateLabel.origin.y = profileImg.y
        dateLabel.text = NSDate(timeIntervalSince1970: clips[playIndex].date).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: nameLabel.height)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.6)
        dateLabel.font = UIFont(name: "OpenSans", size: 12.0)
        
        view.addSubview(textField);
        view.addSubview(profileImg)
        view.addSubview(nameLabel)
        view.addSubview(dateLabel)
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDown)
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
    
    func playPrevClip(){
        
//        nextPlayer = player        
//        player = prevPlayer
        
        playIndex -= 1
        
        player = ClipPlayer(clip: clips[playIndex], frame: self.view.bounds)
        
        textField.text = clips[playIndex].txt
        textField.center.y = self.view.height * clips[playIndex].y
        textField.hidden = textField.text == ""
        dateLabel.text = NSDate(timeIntervalSince1970: clips[playIndex].date).shortTimeAgoSinceNow()
        
        view.layer.addSublayer(player.playerLayer)
        
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.player.currentItem)
        
//        // Cache prev clip
//        if playIndex > 0 {
//            prevPlayer = ClipPlayer(clip: clips[playIndex-1], frame: self.view.bounds)
//        }
    }
    
    func playNextClip(){
        
//        prevPlayer = player        
//        player = nextPlayer
        
        playIndex += 1
        
        player = ClipPlayer(clip: clips[playIndex], frame: self.view.bounds)
        
        textField.text = clips[playIndex].txt
        textField.center.y = self.view.height * clips[playIndex].y
        textField.hidden = textField.text == ""
        dateLabel.text = NSDate(timeIntervalSince1970: clips[playIndex].date).shortTimeAgoSinceNow()
        
        view.layer.addSublayer(player.playerLayer)
        
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.player.currentItem)
        
        
//        // Cache next clip
//        if clips.count > playIndex + 1 {
//            nextPlayer = ClipPlayer(clip: clips[playIndex+1], frame: self.view.bounds)
//        }
    }

    func playerDidFinishPlaying(notification: NSNotification) {
        if clips.count > playIndex + 1 {
            playNextClip()
        } else {
            close()
        }
    }
    
    func close(){
//        player.playerLayer.frame = CGRect(origin: CGPoint(x: 0,y: 0), size:CGSize(width: 150, height: 266))
//        if nextPlayer != nil {
//            nextPlayer.playerLayer.frame = player.playerLayer.frame
//        }
//        if prevPlayer != nil {
//            prevPlayer.playerLayer.frame = player.playerLayer.frame
//        }

        if (friend.clipIndex < playIndex){
            friend.clipIndex = playIndex
            let realm = try! Realm()
            try! realm.write {
                realm.create(UserModel.self, value: ["uid": friend.uid, "clipIndex": friend.clipIndex], update: true)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: playIndex, inSection: 0) , atScrollPosition: .CenteredHorizontally, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

