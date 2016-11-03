//
//  CameraViewController.swift
//  Group
//
//  Created by Hoang Le on 9/6/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary
import MapKit
import SCRecorder

class NCameraViewController: UIViewController, SCRecorderDelegate, CLLocationManagerDelegate {
    
    var recorder: SCRecorder!
    var recordSession: SCRecordSession?
    
    var bottomBar: UIView!
    var loadingView: UIView!
    var previewView: UIView!
    
    var flashModeButton: UIButton!
    
    var switchCameraModeButton: UIButton!
    

    
    var recordButton:RecordButton!
    var progress : CGFloat = 0
    
    // Max duration of the recordButton
    let maxDuration: CGFloat = 10
    
    var locationInfo = LocationInfo()
    let locationManager = CLLocationManager()
    
    var isRecording = false
    var showDoneButton = false
    
    var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //📍Begin setting location
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹                           📹📹📹****/
        /****📹📹📹📹  BEGIN SETTING UP CAMERA  📹📹📹****/
        /****📹📹📹📹                           📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/

        previewView = UIView()
        previewView.frame = view.layer.frame
        view.addSubview(previewView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
        tap.numberOfTapsRequired = 2
        previewView.addGestureRecognizer(tap)

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let frontCamera = (userDefaults.valueForKey("frontCamera") as? Bool) ?? false
        
        recorder = SCRecorder.sharedRecorder()
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.previewView = previewView
        recorder.device = frontCamera ? .Front : .Back
        recorder.mirrorOnFrontCamera = true
        recorder.autoSetVideoOrientation = false
        recorder.delegate = self
        recorder.initializeSessionLazily = false
        recorder.maxRecordDuration = CMTimeMake(Int64(maxDuration), 1)

        //recorder.keepMirroringOnWrite = true
        //recorder.maxRecordDuration = CMTimeMake(10, 1);
        //recorder.fastRecordMethodEnabled = YES;
        
        //self.retakeButton.addTarget(self, action: #selector(self.handleRetakeButtonTapped), forControlEvents: .TouchUpInside)
        //self.stopButton.addTarget(self, action: #selector(self.handleStopButtonTapped), forControlEvents: .TouchUpInside)
        //self.reverseCamera.addTarget(self, action: #selector(self.handleReverseCameraTapped), forControlEvents: .TouchUpInside)
        
        //self.focusView = SCRecorderToolsView(frame: previewView.bounds)
        //self.focusView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        //self.focusView.recorder = recorder
        //previewView.addSubview(self.focusView)
        //self.focusView.outsideFocusTargetImage = UIImage(named: "capture_flip")!
        //self.focusView.insideFocusTargetImage = UIImage(named: "capture_flip")!

        do{
            try recorder.prepare()
        } catch {
            print("Prepare error: \(error)")
        }
        
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        
        // 🔴 Set up the record button
        recordButton = RecordButton(frame: CGRectMake(0,0,80,80))
        recordButton.center = self.view.center
        recordButton.progressColor = .redColor()
        recordButton.buttonColor = UIColor(white: 1, alpha: 0.5)
        recordButton.closeWhenFinished = false
        
        recordButton.addTarget(self, action: #selector(record), forControlEvents: .TouchDown)
        recordButton.addTarget(self, action: #selector(pause), forControlEvents: .TouchUpInside)

        view.addSubview(recordButton)
        self.view.addSubview(recordButton)
        recordButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-15)
            make.centerX.equalTo(self.view)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        let loopIcon = UIImage(named: "ic_loop") as UIImage?
        let flipButton = UIButton(type: .System)
        flipButton.tintColor = UIColor(white: 1, alpha: 0.5)
        flipButton.backgroundColor = UIColor.clearColor()
        flipButton.setImage(loopIcon, forState: .Normal)
        flipButton.addTarget(self, action: #selector(flipCamera), forControlEvents: .TouchUpInside)
        self.view.addSubview(flipButton)
        flipButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let backIcon = UIImage(named: "ic_close") as UIImage?
        let backButton = UIButton(type: .System)
        backButton.tintColor = UIColor(white: 1, alpha: 0.5)
        backButton.backgroundColor = UIColor.clearColor()
        backButton.setImage(backIcon, forState: .Normal)
        backButton.addTarget(self, action: #selector(close), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        backButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(15)
            make.left.equalTo(self.view).offset(18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        let nextIcon = UIImage(named: "ic_blue_arrow") as UIImage?
        doneButton = UIButton(type: .System)
        doneButton.tintColor = UIColor(white: 1, alpha: 1)
        doneButton.backgroundColor = UIColor.clearColor()
        doneButton.setImage(nextIcon, forState: .Normal)
        doneButton.addTarget(self, action: #selector(stop), forControlEvents: .TouchUpInside)
        self.view.addSubview(doneButton)
        doneButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-25)
            make.right.equalTo(self.view).offset(-25)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    func recorder(recorder: SCRecorder, didSkipVideoSampleBufferInSession recordSession: SCRecordSession) {
        print("Skipped video buffer")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        if audioInputError != nil {
            print("Reconfigured audio input: \(audioInputError)")
        }
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        if videoInputError != nil {
            print("Reconfigured video input: \(videoInputError)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let recordSession = recorder.session {
            self.recorder.session = nil
            recordSession.cancelSession(nil)
        }
        self.prepareSession()
        recorder.startRunning()
        locationManager.startUpdatingLocation()
        
        doneButton.alpha = 0
        showDoneButton = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isRecording = false
        progress = 0
        recordButton.buttonState = .Idle
        recorder.stopRunning()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if (segue.destinationViewController is SCSessionListViewController) {
//            var sessionListVC = segue.destinationViewController
//            sessionListVC.recorder = recorder
//        }
//        
//    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        var url = info[UIImagePickerControllerMediaURL]
//        picker!.dismissViewControllerAnimated(true, completion: { _ in })
//        var segment = SCRecordSessionSegment.segmentWithURL(url, info: nil)
//        recorder.session.addSegment(segment)
//        self.recordSession = SCRecordSession.recordSession()
//        recordSession.addSegment(segment)
//        self.showVideo()
//    }
    
    func stop() {
        isRecording = false
        progress = 0
        recordButton.buttonState = .Idle
        recorder.pause {
            self.saveAndShowSession(self.recorder.session!)
        }
    }
    
    func saveAndShowSession(recordSession: SCRecordSession) {        
//        SCRecordSessionManager.sharedInstance().saveRecordSession(recordSession)
        self.recordSession = recordSession
        self.showVideo()
    }
    
    func showVideo(){
        let videoPlayer = NCameraPreviewController()
        videoPlayer.recordSession = recordSession
        videoPlayer.locationInfo = self.locationInfo
        self.presentViewController(videoPlayer, animated: true, completion: nil)        
    }
    
    func handleRetakeButtonTapped(sender: AnyObject) {
//        if let recordSession = recorder.session {
//            self.recorder.session = nil
//            // If the recordSession was saved, we don't want to completely destroy it
//            if SCRecordSessionManager.sharedInstance().isSaved(recordSession) {
//                recordSession.endSegmentWithInfo(nil, completionHandler: nil)
//            }
//            else {
//                recordSession.cancelSession(nil)
//            }
//        }
//        self.prepareSession()
    }
    
    func switchCameraMode(sender: AnyObject) {
//        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
//            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {() -> Void in
//                self.capturePhotoButton.alpha() = 0.0
//                self.recordView.alpha() = 1.0
//                self.retakeButton.alpha() = 1.0
//                self.stopButton.alpha() = 1.0
//                }, completion: {(finished: Bool) -> Void in
//                    self.recorder.captureSessionPreset = kVideoPreset
//                    self.switchCameraModeButton.setTitle("Switch Photo", forState: .Normal)
//                    self.flashModeButton.setTitle("Flash : Off", forState: .Normal)
//                    self.recorder.flashMode = SCFlashModeOff
//            })
//        }
//        else {
//            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {() -> Void in
//                self.recordView.alpha() = 0.0
//                self.retakeButton.alpha() = 0.0
//                self.stopButton.alpha() = 0.0
//                self.capturePhotoButton.alpha() = 1.0
//                }, completion: {(finished: Bool) -> Void in
//                    self.recorder.captureSessionPreset = AVCaptureSessionPresetPhoto
//                    self.switchCameraModeButton.setTitle("Switch Video", forState: .Normal)
//                    self.flashModeButton.setTitle("Flash : Auto", forState: .Normal)
//                    self.recorder.flashMode = SCFlashModeAuto
//            })
//        }
    }
    
    func switchFlash(sender: AnyObject) {
//        var flashModeString: String? = nil
//        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
//            switch recorder.flashMode {
//            case SCFlashModeAuto:
//                flashModeString = "Flash : Off"
//                self.recorder.flashMode = SCFlashModeOff
//            case SCFlashModeOff:
//                flashModeString = "Flash : On"
//                self.recorder.flashMode = SCFlashModeOn
//            case SCFlashModeOn:
//                flashModeString = "Flash : Light"
//                self.recorder.flashMode = SCFlashModeLight
//            case SCFlashModeLight:
//                flashModeString = "Flash : Auto"
//                self.recorder.flashMode = SCFlashModeAuto
//            default:
//                break
//            }
//        }
//        else {
//            switch recorder.flashMode {
//            case SCFlashModeOff:
//                flashModeString = "Flash : On"
//                self.recorder.flashMode = SCFlashModeLight
//            case SCFlashModeLight:
//                flashModeString = "Flash : Off"
//                self.recorder.flashMode = SCFlashModeOff
//            default:
//                break
//            }
//        }
//        self.flashModeButton.setTitle(flashModeString, forState: .Normal)
    }
    
    func prepareSession() {
        if recorder.session == nil {
            let session = SCRecordSession()
            session.fileType = AVFileTypeQuickTimeMovie
            self.recorder.session = session
        }
        self.updateTime()
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession recordSession: SCRecordSession) {
        print("Record session completed")
        isRecording = false
        progress = 0
        recordButton.buttonState = .Idle
        self.saveAndShowSession(recordSession)
    }
    
    func recorder(recorder: SCRecorder, didInitializeAudioInSession recordSession: SCRecordSession, error: NSError?) {
        if error == nil {
            print("Initialized audio in record session")
        }
        else {
            print("Failed to initialize audio in record session: \(error!.localizedDescription)")
        }
    }
    
    func recorder(recorder: SCRecorder, didInitializeVideoInSession recordSession: SCRecordSession, error: NSError?) {
        if error != nil {
            print("Failed to initialize video in record session: \(error!.localizedDescription)")
        }
        else {
        }
    }
    
    func recorder(recorder: SCRecorder, didBeginSegmentInSession recordSession: SCRecordSession, error: NSError?) {
        if error != nil {
            print("Error begin record segment: \(error)")
        }
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession recordSession: SCRecordSession, error: NSError?) {
        guard error == nil, let segment = segment else {
            if error != nil {
                print("Error complete record segment: \(error)")
            }
            return
        }
        print("Record segment completed: \(segment.url), frameRate: \(segment.frameRate)")
    }
    
    func record(){
        if !isRecording {
            print("Recording...")
            isRecording = true
            recorder.record()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func pause(){
        recorder.pause()
        isRecording = false
    }
    
    func updateTime() {
        var currentTime = kCMTimeZero
        if let session = recorder.session {
            currentTime = session.duration
        }
        //self.timeRecordedLabel.text! = String(format: "%.2f sec", CMTimeGetSeconds(currentTime))
        
        let seconds = CMTimeGetSeconds(currentTime)
        progress = CGFloat(seconds) / maxDuration
        recordButton.setProgress(progress)
        
        if !showDoneButton && seconds >= 1 {
            showDoneButton = true
            UIView.animateWithDuration(1.5, animations: {
                self.doneButton.alpha = 1.0
            })
        }
        
        //print(seconds)
        //if progress >= 1 {
        //    stop()
        //}
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession recordSession: SCRecordSession) {
        updateTime()
    }
    
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        locationManager.stopUpdatingLocation()
        locationInfo.load(location)
    }
    
    func close() {
        isRecording = false
        progress = 0
        recordButton.buttonState = .Idle
        recorder.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func flipCamera() {
        recorder.switchCaptureDevices()
        let frontCamera = recorder.device == .Front
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(frontCamera, forKey: "frontCamera")
        //userDefaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
