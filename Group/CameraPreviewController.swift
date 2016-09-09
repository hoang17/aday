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
    var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = NSURL(fileURLWithPath: outputPath)
        let asset = AVAsset(URL: outputFileURL)
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
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
        
//        textField.translatesAutoresizingMaskIntoConstraints = false
        
//        let horizontalConstraint = NSLayoutConstraint(item: textField, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)        
//        let verticalConstraint = NSLayoutConstraint(item: textField, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
//        bottomConstraint = NSLayoutConstraint(item: textField, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: -300)
//        let widthConstraint = NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: textField, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 36)

//        view.addConstraint(horizontalConstraint)
//        view.addConstraint(verticalConstraint)
//        view.addConstraint(topConstraint)
//        view.addConstraint(bottomConstraint!)
//        view.addConstraint(widthConstraint)
//        view.addConstraint(heightConstraint)
        
//        textField.snp_makeConstraints { (make) -> Void in
//            //self.bottomConstraint = make.bottom.equalTo(self.view).constraint
//            make.left.equalTo(self.view).offset(0)
//            make.right.equalTo(self.view).offset(0)
//            make.height.equalTo(36)
//        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillHideNotification, object: nil)
    
        tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        self.view.addGestureRecognizer(tap!)

    }
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurve?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let options:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)

            print(keyboardSize.height)
            
            self.bottomConstraint?.constant = -keyboardSize.height
            
            UIView.animateWithDuration(0.2, animations: {
                self.textField.origin.y = self.view.height - keyboardSize.height - self.textField.height
//                self.view.layoutIfNeeded()
            })

//            self.bottomConstraint!.updateOffset(-keyboardFrame.height)

//            textField.snp_updateConstraints { (make) -> Void in
//                make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
//            }

            
//            UIView.animateWithDuration(duration,
//                                       delay: NSTimeInterval(0),
//                                       options: options,
//                                       animations: { self.view.layoutIfNeeded() },
//                                       completion: nil)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if textField.hidden {
            textField.hidden = false
            self.textField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        
        if let touch = touches.first {
            let location = touch.locationInView(self.view)
            UIView.animateWithDuration(0.2, animations: {
                self.textField.center.y = location.y
                }, completion: { (Bool) -> Void in
                    self.textField.userInteractionEnabled = true
            })
        }
        
    }
    
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        textField.layoutIfNeeded()
//    }
    
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

