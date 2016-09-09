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
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var nextPlayer: AVPlayer?
    var nextPlayerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**** Download clips ****/
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        for clip in clips {
            
            let fileName = clip.fname
            
            // Check if file not existed then download
            let filePath = NSTemporaryDirectory() + fileName;
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                print("File existed " + fileName)
                
            } else{
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if (error != nil) {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                    }
                }
            }
        }
        
        /**** Done download clips ****/
        
        // Play current clip
        let outputPath = NSTemporaryDirectory() + clips[playerIndex].fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.view!.bounds
        view.layer.addSublayer(playerLayer!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player!.currentItem)
        player!.play()
        
        // Cache next clip
        if (clips.count > playerIndex + 1) {
            let outputPath = NSTemporaryDirectory() + clips[playerIndex+1].fname
            let fileUrl = NSURL(fileURLWithPath: outputPath)
            nextPlayer = AVPlayer(URL: fileUrl)
            nextPlayerLayer = AVPlayerLayer(player: nextPlayer)
            nextPlayerLayer!.frame = self.view!.bounds
        }
        
//        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
//        textField.textColor = UIColor.whiteColor()
//        textField.font = UIFont.systemFontOfSize(17.0)
//        textField.textAlignment = NSTextAlignment.Center
//        textField.text = ""
//        textField.hidden = true
//        textField.height = 36
//        textField.width = UIScreen.mainScreen().bounds.width
//        textField.userInteractionEnabled = true
//        
//        view.addSubview(textField);
//        view.bringSubviewToFront(textField)
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        view.addGestureRecognizer(tap)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDown)
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        view.addGestureRecognizer(swipeRight)
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
//        view.addGestureRecognizer(pan)

    }

    func swipeDownGesture(){
        player?.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player!.currentItem)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    var interactor:Interactor? = nil
//    
//    func panGesture(sender: UIPanGestureRecognizer) {
//        
//        let percentThreshold:CGFloat = 0.3
//        
//        // convert y-position to downward pull progress (percentage)
//        let translation = sender.translationInView(view)
//        let verticalMovement = translation.y / view.bounds.height
//        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
//        let downwardMovementPercent = fminf(downwardMovement, 1.0)
//        let progress = CGFloat(downwardMovementPercent)
//        
//        guard let interactor = interactor else { return }
//        
//        switch sender.state {
//        case .Began:
//            interactor.hasStarted = true
//            dismissViewControllerAnimated(true, completion: nil)
//        case .Changed:
//            interactor.shouldFinish = progress > percentThreshold
//            interactor.updateInteractiveTransition(progress)
//        case .Cancelled:
//            interactor.hasStarted = false
//            interactor.cancelInteractiveTransition()
//        case .Ended:
//            interactor.hasStarted = false
//            interactor.shouldFinish
//                ? interactor.finishInteractiveTransition()
//                : interactor.cancelInteractiveTransition()
//        default:
//            break
//        }
//    }
    
//    func swipeRightGesture(){
//        player?.pause()
//        NSNotificationCenter.defaultCenter().removeObserver(self,
//                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                            object:player!.currentItem)
//        if (playerIndex > 0) {
//            playPrevClip()
//        } else {
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }

    func tapGesture(){
        player?.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object:player!.currentItem)
        if (clips.count > playerIndex + 1) {
            playNextClip()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func playPrevClip(){
        // Cache next clip
        nextPlayer = player
        nextPlayerLayer = playerLayer
        
        playerIndex -= 1
        let outputPath = NSTemporaryDirectory() + clips[playerIndex].fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.view!.bounds
        view.layer.addSublayer(playerLayer!)
        player!.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player!.currentItem)
    }
    
    func playNextClip(){
        playerLayer?.removeFromSuperlayer()
        player = nextPlayer
        playerLayer = nextPlayerLayer
        view.layer.addSublayer(playerLayer!)
        player!.play()
        playerIndex += 1
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player!.currentItem)
        
        // Cache next clip
        if (clips.count > playerIndex + 1) {
            let outputPath = NSTemporaryDirectory() + clips[playerIndex+1].fname
            let fileUrl = NSURL(fileURLWithPath: outputPath)
            nextPlayer = AVPlayer(URL: fileUrl)
            nextPlayerLayer = AVPlayerLayer(player: nextPlayer)
            nextPlayerLayer!.frame = self.view!.bounds
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

