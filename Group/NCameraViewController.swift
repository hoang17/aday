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

        let userDefaults = UserDefaults.standard
        let frontCamera = (userDefaults.value(forKey: "frontCamera") as? Bool) ?? false
        
        recorder = SCRecorder.shared()
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.previewView = previewView
        recorder.device = frontCamera ? .front : .back
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
        recordButton = RecordButton(frame: CGRect(x: 0,y: 0,width: 80,height: 80))
        recordButton.center = self.view.center
        recordButton.progressColor = .red
        recordButton.buttonColor = UIColor(white: 1, alpha: 0.5)
        recordButton.closeWhenFinished = false
        
        recordButton.addTarget(self, action: #selector(record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(pause), for: .touchUpInside)

        view.addSubview(recordButton)
        self.view.addSubview(recordButton)
        recordButton.snp_makeConstraints { [weak self] (make) in
            make.bottom.equalTo(self!.view).offset(-15)
            make.centerX.equalTo(self!.view)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        let loopIcon = UIImage(named: "ic_loop") as UIImage?
        let flipButton = UIButton(type: .system)
        flipButton.tintColor = UIColor(white: 1, alpha: 0.5)
        flipButton.backgroundColor = UIColor.clear
        flipButton.setImage(loopIcon, for: UIControlState())
        flipButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        self.view.addSubview(flipButton)
        flipButton.snp_makeConstraints { [weak self] (make) in
            make.top.equalTo(self!.view).offset(15)
            make.right.equalTo(self!.view).offset(-18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let closeIcon = UIImage(named: "ic_close") as UIImage?
        let closeButton = UIButton(type: .system)
        closeButton.tintColor = UIColor(white: 1, alpha: 0.5)
        closeButton.backgroundColor = UIColor.clear
        closeButton.setImage(closeIcon, for: UIControlState())
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp_makeConstraints { [weak self] (make) in
            make.top.equalTo(self!.view).offset(15)
            make.left.equalTo(self!.view).offset(18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        let nextIcon = UIImage(named: "ic_blue_arrow") as UIImage?
        doneButton = UIButton(type: .system)
        doneButton.tintColor = UIColor(white: 1, alpha: 1)
        doneButton.backgroundColor = UIColor.clear
        doneButton.setImage(nextIcon, for: UIControlState())
        doneButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        self.view.addSubview(doneButton)
        doneButton.snp_makeConstraints { [weak self] (make) in
            make.bottom.equalTo(self!.view).offset(-25)
            make.right.equalTo(self!.view).offset(-25)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    func recorder(_ recorder: SCRecorder, didSkipVideoSampleBufferIn recordSession: SCRecordSession) {
        print("Skipped video buffer")
    }
    
    func recorder(_ recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        if audioInputError != nil {
            print("Reconfigured audio input: \(audioInputError)")
        }
    }
    
    func recorder(_ recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        if videoInputError != nil {
            print("Reconfigured video input: \(videoInputError)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let recordSession = recorder.session {
            self.recorder.session = nil
            recordSession.cancel(nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isRecording = false
        progress = 0
        recordButton.buttonState = .idle
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
        recordButton.buttonState = .idle
        recorder.pause {
            self.saveAndShowSession(self.recorder.session!)
        }
    }
    
    func saveAndShowSession(_ recordSession: SCRecordSession) {        
//        SCRecordSessionManager.sharedInstance().saveRecordSession(recordSession)
        self.recordSession = recordSession
        self.showVideo()
    }
    
    func showVideo(){
        let videoPlayer = NCameraPreviewController()
        videoPlayer.recordSession = recordSession
        videoPlayer.locationInfo = self.locationInfo
        self.present(videoPlayer, animated: true, completion: nil)        
    }
    
    func handleRetakeButtonTapped(_ sender: AnyObject) {
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
    
    func switchCameraMode(_ sender: AnyObject) {
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
    
    func switchFlash(_ sender: AnyObject) {
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
    
    func recorder(_ recorder: SCRecorder, didComplete recordSession: SCRecordSession) {
        print("Record session completed")
        isRecording = false
        progress = 0
        recordButton.buttonState = .idle
        self.saveAndShowSession(recordSession)
    }
    
    func recorder(_ recorder: SCRecorder, didInitializeAudioIn recordSession: SCRecordSession, error: NSError?) {
        if error == nil {
            print("Initialized audio in record session")
        }
        else {
            print("Failed to initialize audio in record session: \(error!.localizedDescription)")
        }
    }
    
    func recorder(_ recorder: SCRecorder, didInitializeVideoIn recordSession: SCRecordSession, error: NSError?) {
        if error != nil {
            print("Failed to initialize video in record session: \(error!.localizedDescription)")
        }
        else {
        }
    }
    
    func recorder(_ recorder: SCRecorder, didBeginSegmentIn recordSession: SCRecordSession, error: NSError?) {
        if error != nil {
            print("Error begin record segment: \(error)")
        }
    }
    
    func recorder(_ recorder: SCRecorder, didComplete segment: SCRecordSessionSegment?, in recordSession: SCRecordSession, error: NSError?) {
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
            UIView.animate(withDuration: 0.5, animations: {
                self.doneButton.alpha = 1.0
            })
        }
        
        //print(seconds)
        //if progress >= 1 {
        //    stop()
        //}
    }
    
    func recorder(_ recorder: SCRecorder, didAppendVideoSampleBufferIn recordSession: SCRecordSession) {
        updateTime()
    }
    
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        locationManager.stopUpdatingLocation()
        locationInfo.load(location)
    }
    
    func close() {
        isRecording = false
        progress = 0
        recordButton.buttonState = .idle
        recorder.stopRunning()
        self.dismiss(animated: true, completion: nil)
    }
    
    func flipCamera() {
        recorder.switchCaptureDevices()
        let frontCamera = recorder.device == .front
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(frontCamera, forKey: "frontCamera")
        //userDefaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
