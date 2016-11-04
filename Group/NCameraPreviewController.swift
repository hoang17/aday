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

class NCameraPreviewController: UIViewController, SCPlayerDelegate {

    let textField = PinTextView()
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
        textField.returnKeyType = UIReturnKeyType.Default
        textField.userInteractionEnabled = true
        textField.maxLength = 200
        textField.maxHeight = 120
        //textField.textContainer.maximumNumberOfLines = 5
        //textField.textContainer.lineBreakMode = .ByTruncatingTail
        
        view.addSubview(textField)
        
        let closeIcon = UIImage(named: "ic_close") as UIImage?
        let closeButton = UIButton(type: .System)
        closeButton.tintColor = UIColor(white: 1, alpha: 0.5)
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.setImage(closeIcon, forState: .Normal)
        closeButton.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp_makeConstraints { [weak self] (make) in
            make.top.equalTo(self!.view).offset(15)
            make.left.equalTo(self!.view).offset(18)
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
        doneButton.snp_makeConstraints { [weak self] (make) in
            make.bottom.equalTo(self!.view).offset(-25)
            make.right.equalTo(self!.view).offset(-25)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
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
        
        recordSession?.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality) { [weak self] (url, error) in
            if error == nil {

                print("Video saved to disk: \(url)")
                
                let id = FIRDatabase.database().reference().child("clips").childByAutoId().key
                let uid = AppDelegate.uid
                let uname = AppDelegate.name
                let txt = self?.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let y = self!.textLocation.y/self!.view.frame.height
                let uploadFile = "\(id).mp4"
                
                let clip = ClipModel(id: id, uid: uid, uname: uname, fname: uploadFile, txt: txt!, y: y, locationInfo: self!.locationInfo!)
                
                UploadHelper.sharedInstance.enqueueUpload(clip, liloaded: self!.locationInfo!.loaded)
                
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
    
    // Allow dragging textfield
    func panGesture(sender:UIPanGestureRecognizer) {
        let translation  = sender.translationInView(self.view)
        textLocation = CGPointMake(sender.view!.center.x, sender.view!.center.y + translation.y)
        sender.view!.center = textLocation
        sender.setTranslation(CGPointZero, inView: self.view)
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
    
    func back(){
        player?.pause()
        self.dismissViewControllerAnimated(true, completion:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(textField)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        print("deinit camera preview")
        player?.replaceCurrentItemWithPlayerItem(nil)
        player = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
