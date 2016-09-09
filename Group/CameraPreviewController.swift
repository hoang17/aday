//
//  PreviewController.swift
//  Group
//
//  Created by Hoang Le on 9/7/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVKit
import AVFoundation
//import SnapKit

class CameraPreviewController: AVPlayerViewController {

    let textField = UITextField()
    var tap: UITapGestureRecognizer?
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = NSURL(fileURLWithPath: outputPath)
        let asset = AVAsset(URL: outputFileURL)
        self.showsPlaybackControls = false
        self.player = AVPlayer(playerItem: AVPlayerItem(asset:asset))
        self.player!.actionAtItemEnd = .None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player!.currentItem)
        self.player?.play()
        
        let backIcon = UIImage(named: "ic_close") as UIImage?
        let backButton = UIButton(type: .System)
        backButton.tintColor = UIColor(white: 1, alpha: 0.5)
        backButton.backgroundColor = UIColor.clearColor()
        backButton.setImage(backIcon, forState: .Normal)
        backButton.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        self.view.bringSubviewToFront(backButton)
        backButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(15)
            make.left.equalTo(self.view).offset(18)
            make.width.equalTo(26)
            make.height.equalTo(26)
        }
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(17.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.text = ""
        textField.hidden = true
        textField.height = 36
        textField.width = UIScreen.mainScreen().bounds.width
        view.addSubview(textField);
        view.bringSubviewToFront(textField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)

        tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        self.view.addGestureRecognizer(tap!)

        let pan = UIPanGestureRecognizer(target:self, action:#selector(panGesture))
        textField.addGestureRecognizer(pan)
        
        textField.userInteractionEnabled = true
    }
    
    func panGesture(sender:UIPanGestureRecognizer) {
        let translation  = sender.translationInView(self.view)
        let x = sender.view!.center.x
        let y = sender.view!.center.y
//        sender.view?.center = CGPointMake(x + translation.x, y + translation.y)
        sender.view?.center = CGPointMake(x, y + translation.y)
        sender.setTranslation(CGPointZero, inView: self.view)
        
        textLocation = sender.view!.center;
        
//        textField.center = sender.locationInView(self.view)
    }
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
//            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurve?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
//            let options:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            UIView.animateWithDuration(duration, animations: {
                self.textField.origin.y = self.view.height - keyboardSize.height - self.textField.height
            })
            
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if textField.hidden {
            if let touch = touches.first {
                textLocation = touch.locationInView(self.view)
                textField.center.y = textLocation.y
                textField.hidden = false
                textField.becomeFirstResponder()
            }
            
        } else {
            textField.resignFirstResponder()
            
            if (textField.text == ""){
                textField.hidden = true
            } else {
                UIView.animateWithDuration(0.2, animations: {
                    self.textField.center.y = self.textLocation.y
                    }, completion: { (Bool) -> Void in
                        self.textField.userInteractionEnabled = true
                })
            }
        }
    }
    
    
    func tapGesture(sender:UITapGestureRecognizer){
        
        let location = sender.locationInView(self.view)
        
        print("tap \(location)")
        
        UIView.animateWithDuration(0.2, animations: {
            self.textField.center.y = location.y
            }, completion: { (Bool) -> Void in
                self.textField.userInteractionEnabled = true
                self.textField.becomeFirstResponder()
        })

    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
        }

    }
    
    func back(){
        self.dismissViewControllerAnimated(true) {
            //
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

