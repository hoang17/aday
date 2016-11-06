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
        
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField.textColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.textAlignment = NSTextAlignment.center
        textField.text = ""
        textField.isHidden = true
        textField.height = 34
        textField.width = UIScreen.main.bounds.width
        textField.returnKeyType = UIReturnKeyType.default
        textField.isUserInteractionEnabled = true
        textField.maxLength = 200
        textField.maxHeight = 120
        //textField.textContainer.maximumNumberOfLines = 5
        //textField.textContainer.lineBreakMode = .ByTruncatingTail
        
        view.addSubview(textField)
        
        let closeIcon = UIImage(named: "ic_close") as UIImage?
        let closeButton = UIButton(type: .system)
        closeButton.tintColor = UIColor(white: 1, alpha: 0.5)
        closeButton.backgroundColor = UIColor.clear
        closeButton.setImage(closeIcon, for: UIControlState())
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { [weak self] (make) in
            make.top.equalTo(self!.view).offset(15)
            make.left.equalTo(self!.view).offset(18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let nextIcon = UIImage(named: "ic_blue_arrow") as UIImage?
        let doneButton = UIButton(type: .system)
        doneButton.tintColor = UIColor(white: 1, alpha: 1)
        doneButton.backgroundColor = UIColor.clear
        doneButton.setImage(nextIcon, for: UIControlState())
        doneButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        self.view.addSubview(doneButton)
        doneButton.snp.makeConstraints { [weak self] (make) in
            make.bottom.equalTo(self!.view).offset(-25)
            make.right.equalTo(self!.view).offset(-25)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let pan = UIPanGestureRecognizer(target:self, action:#selector(panGesture))
        textField.addGestureRecognizer(pan)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.setItemBy(recordSession!.assetRepresentingSegments())
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    func submit() {
        
        _ = recordSession?.mergeSegments(usingPreset: AVAssetExportPresetHighestQuality) { [weak self] (url, error) in
            if error == nil {

                print("Video saved to disk: \(url)")
                
                let id = FIRDatabase.database().reference().child("clips").childByAutoId().key
                let uid = AppDelegate.uid
                let uname = AppDelegate.name
                let txt = self?.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let y = self!.textLocation.y/self!.view.frame.height
                let uploadFile = "\(id).mp4"
                
                let clip = ClipModel(id: id, uid: uid, uname: uname, fname: uploadFile, txt: txt!, y: y, locationInfo: self!.locationInfo!)
                
                UploadHelper.sharedInstance.enqueueUpload(clip, liloaded: self!.locationInfo!.loaded)
                
                (url! as NSURL).saveToCameraRoll(completion: {(path, saveError) in
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
    func panGesture(_ sender:UIPanGestureRecognizer) {
        let translation  = sender.translation(in: self.view)
        textLocation = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y + translation.y)
        sender.view!.center = textLocation
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    // Show textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // locationField.resignFirstResponder()
        
        if textField.isHidden {
            if let touch = touches.first {
                textLocation = touch.location(in: self.view)
                textField.center.y = textLocation.y
                textField.isHidden = false
                textField.becomeFirstResponder()
            }
            
        } else {
            textField.resignFirstResponder()
            
            if (textField.text == ""){
                textField.isHidden = true
            } else {
                UIView.animate(withDuration: 0.2, animations: { self.textField.center.y = self.textLocation.y }, completion: nil)
            }
        }
    }
    
    func back(){
        player?.pause()
        self.dismiss(animated: true, completion:nil)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(textField)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit {
        print("deinit camera preview")
        player?.replaceCurrentItem(with: nil)
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}
