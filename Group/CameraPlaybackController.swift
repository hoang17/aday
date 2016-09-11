//
//  CameraPreviewController.swift
//  Group
//
//  Created by Hoang Le on 9/7/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVKit
import AVFoundation
import SnapKit
import FirebaseStorage
import FirebaseAuth
import DigitsKit

class CameraPlaybackController: UIViewController, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var clips = [Clip]()
    var playerIndex = 0
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var nextPlayer: AVPlayer!
    var nextPlayerLayer: AVPlayerLayer!
    var profileImg = UIImageView()
    var nameLabel = UILabel()
    var dateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Play current clip
        let outputPath = NSTemporaryDirectory() + clips[playerIndex].fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view!.bounds
        view.layer.addSublayer(playerLayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.currentItem)
        player.play()
        
        // Cache next clip
        if (clips.count > playerIndex + 1) {
            let outputPath = NSTemporaryDirectory() + clips[playerIndex+1].fname
            let fileUrl = NSURL(fileURLWithPath: outputPath)
            nextPlayer = AVPlayer(URL: fileUrl)
            nextPlayerLayer = AVPlayerLayer(player: nextPlayer)
            nextPlayerLayer.frame = self.view!.bounds
        }
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(17.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.height = 36
        textField.width = UIScreen.mainScreen().bounds.width
        textField.userInteractionEnabled = false
        textField.text = clips[playerIndex].txt
        textField.center.y = playerLayer.frame.height * clips[playerIndex].y
        
        if (textField.text == "") {
            textField.hidden = true
        }

        
        view.addSubview(textField);
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDown)
        
        profileImg.origin = CGPoint(x: 20, y: 20)
        profileImg.size = CGSize(width: 30, height: 30)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        
        nameLabel.origin = CGPoint(x: 60, y: 20)
        nameLabel.height = 28
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.boldSystemFontOfSize(12)
        
        dateLabel.origin.y = 20
        dateLabel.size = CGSize(width: 50, height: 25)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.5)
        dateLabel.font = UIFont.systemFontOfSize(12)
        
        view.addSubview(profileImg)
        view.addSubview(nameLabel)
        view.addSubview(dateLabel)
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        
        player?.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player.currentItem)
        
        let location = sender.locationInView(self.view)
        
        if (location.x > 0.25*UIScreen.mainScreen().bounds.width){
            if (clips.count > playerIndex + 1) {
                playNextClip()
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            if (playerIndex > 0) {
                playPrevClip()
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        
    }
    
    func swipeDownGesture(){
        player?.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player.currentItem)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playPrevClip(){
        // Cache next clip
        nextPlayer = player
        nextPlayerLayer = playerLayer
        
        playerIndex -= 1
        
        textField.text = clips[playerIndex].txt
        textField.center.y = playerLayer.frame.height * clips[playerIndex].y
        textField.hidden = textField.text == ""
        
        let outputPath = NSTemporaryDirectory() + clips[playerIndex].fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view!.bounds
        view.layer.addSublayer(playerLayer)
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        
        player.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.currentItem)
    }
    
    func playNextClip(){
        
        playerIndex += 1
        
        textField.text = clips[playerIndex].txt
        textField.center.y = playerLayer.frame.height * clips[playerIndex].y
        textField.hidden = textField.text == ""
        
        playerLayer?.removeFromSuperlayer()
        player = nextPlayer
        playerLayer = nextPlayerLayer
        view.layer.addSublayer(playerLayer)
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(profileImg)
        view.bringSubviewToFront(nameLabel)
        view.bringSubviewToFront(dateLabel)
        
        player.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player.currentItem)
        
        
        // Cache next clip
        if (clips.count > playerIndex + 1) {
            let outputPath = NSTemporaryDirectory() + clips[playerIndex+1].fname
            let fileUrl = NSURL(fileURLWithPath: outputPath)
            nextPlayer = AVPlayer(URL: fileUrl)
            nextPlayerLayer = AVPlayerLayer(player: nextPlayer)
            nextPlayerLayer.frame = self.view!.bounds
        }
    }

    func playerDidFinishPlaying(notification: NSNotification) {
        if (clips.count > playerIndex + 1) {
            playNextClip()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

