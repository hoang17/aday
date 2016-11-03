//
//  CameraPreviewController.swift
//  Group
//
//  Created by Hoang Le on 9/7/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth
import SnapKit
import SCRecorder

class NCameraPreviewController: UIViewController, SCPlayerDelegate, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var locationInfo: LocationInfo?
    
    var player: SCPlayer!
    var recordSession: SCRecordSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.exportView.clipsToBounds = true
//        self.exportView.layer.cornerRadius = 20
//        var saveButton = UIBarButtonItem(title: "Save", style: .Bordered, target: self, action: #selector(self.saveToCameraRoll))
//        var addButton = UIBarButtonItem(title: "Add", style: .Bordered, target: self, action: #selector(self.startMediaBrowser))
//        self.navigationItem.rightBarButtonItems = [saveButton, addButton]
        self.player = SCPlayer()
//        if NSProcessInfo.processInfo().activeProcessorCount > 1 {
//            self.filterSwitcherView.contentMode = .ScaleAspectFill
//            var emptyFilter = SCFilter.emptyFilter()
//            emptyFilter.name() = "#nofilter"
//            self.filterSwitcherView.filters = [emptyFilter, SCFilter.filterWithCIFilterName("CIPhotoEffectNoir"), SCFilter.filterWithCIFilterName("CIPhotoEffectChrome"), SCFilter.filterWithCIFilterName("CIPhotoEffectInstant"), SCFilter.filterWithCIFilterName("CIPhotoEffectTonal"), SCFilter.filterWithCIFilterName("CIPhotoEffectFade"),     // Adding a filter created using CoreImageShop
//                SCFilter.filterWithContentsOfURL(NSBundle.mainBundle().URLForResource("a_filter", withExtension: "cisf")!), self.createAnimatedFilter()]
//            self.player.SCImageView = self.filterSwitcherView
//            self.filterSwitcherView.addObserver(self, forKeyPath: "selectedFilter", options: .New, context: nil)
//        }
        
        let playerView = SCVideoPlayerView(player: player)
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.frame = view.frame
        view.addSubview(playerView)
        
        //playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask
        //self.filterSwitcherView.superview!.insertSubview(playerView, aboveSubview: self.filterSwitcherView)
        //self.filterSwitcherView.removeFromSuperview()
        
        self.player.loopEnabled = true
        
        
//        let asset = AVAsset(URL: UploadHelper.sharedInstance.fileUrl)
//        self.showsPlaybackControls = false
//        self.player = AVPlayer(playerItem: AVPlayerItem(asset:asset))
//        self.videoGravity = AVLayerVideoGravityResizeAspectFill
//        self.player!.actionAtItemEnd = .None
        
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: #selector(playerDidFinishPlaying),
//            name: AVPlayerItemDidPlayToEndTimeNotification,
//            object: player?.currentItem)
//        
//        self.player?.play()
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(16.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.text = ""
        textField.hidden = true
        textField.height = 34
        textField.width = UIScreen.mainScreen().bounds.width
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyType.Done
        textField.userInteractionEnabled = true
        
        view.addSubview(textField)
        view.bringSubviewToFront(textField)
        
        
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
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let nextIcon = UIImage(named: "ic_blue_arrow") as UIImage?
        let doneButton = UIButton(type: .System)
        doneButton.tintColor = UIColor(white: 1, alpha: 1)
        doneButton.backgroundColor = UIColor.clearColor()
        doneButton.setImage(nextIcon, forState: .Normal)
        doneButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
        self.view.addSubview(doneButton)
        self.view.bringSubviewToFront(doneButton)
        doneButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.right.equalTo(self.view).offset(-20)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)

        let pan = UIPanGestureRecognizer(target:self, action:#selector(panGesture))
        textField.addGestureRecognizer(pan)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        player.setItemByAsset(recordSession!.assetRepresentingSegments())
        player.play()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    
    func submit() {
        
        recordSession?.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality) { (url, error) in
            if error == nil {

                print("Video saved to disk: \(url)")
                
                let id = FIRDatabase.database().reference().child("clips").childByAutoId().key
                let uid = AppDelegate.uid
                let uname = AppDelegate.name
                let txt = self.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let y = self.textLocation.y/self.view.frame.height
                let uploadFile = "\(id).mp4"
                
                let clip = ClipModel(id: id, uid: uid, uname: uname, fname: uploadFile, txt: txt!, y: y, locationInfo: self.locationInfo!)
                
                UploadHelper.sharedInstance.enqueueUpload(clip, liloaded: self.locationInfo!.loaded)
                
                url!.saveToCameraRollWithCompletion({(path, saveError) in
                    print("Video saved to camera roll: \(path)")
                })
            }
            else {
                print("Bad things happened: \(error)")
            }
        }

        self.back()
    }
    
    // Limit text length to textfield width
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let combinedString = textField.attributedText!.mutableCopy() as! NSMutableAttributedString
        combinedString.replaceCharactersInRange(range, withString: string)
        return combinedString.size().width < textField.bounds.size.width-10
        
    }
    
    // On return done editing
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text == ""){
            textField.hidden = true
        } else {
            UIView.animateWithDuration(0.2, animations: { self.textField.center.y = self.textLocation.y }, completion: nil)
        }
        return true
    }
    
    // Allow dragging textfield
    func panGesture(sender:UIPanGestureRecognizer) {
        let translation  = sender.translationInView(self.view)
        textLocation = CGPointMake(sender.view!.center.x, sender.view!.center.y + translation.y)
        sender.view!.center = textLocation
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    // Move textfield ontop of keyboard
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animateWithDuration(duration, animations: {
                self.textField.origin.y = self.view.height - keyboardSize.height - self.textField.height
            })
            
        }
    }

    // Show textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // locationField.resignFirstResponder()
        
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
                UIView.animateWithDuration(0.2, animations: { self.textField.center.y = self.textLocation.y }, completion: nil)
            }
        }
    }
    
    // Auto rewind player
    func playerDidFinishPlaying(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
        }
    }
    
    func back(){
        player?.pause()
        self.dismissViewControllerAnimated(true) {
            //
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        player?.replaceCurrentItemWithPlayerItem(nil)
        player = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}