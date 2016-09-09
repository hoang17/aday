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

class CameraPlaybackController: AVPlayerViewController, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var outputFileURL:NSURL?
    var fileName = "output.mp4"

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputPath = NSTemporaryDirectory() + fileName
        outputFileURL = NSURL(fileURLWithPath: outputPath)
        
        let asset = AVAsset(URL: outputFileURL!)
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
        
        
    }

    // Auto rewind player
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

