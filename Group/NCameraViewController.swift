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
    var progressTimer : NSTimer!
    var progress : CGFloat! = 0
    
    // Max duration of the recordButton
    let maxDuration: CGFloat! = 10
    
//    let captureSession = AVCaptureSession()
//    var videoDevice:AVCaptureDevice?
//    var audioDevice:AVCaptureDevice?
//    var videoInput: AVCaptureDeviceInput?
//    var videoFileOutput:AVCaptureMovieFileOutput?
//    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    let outputPath = NSTemporaryDirectory() + "output.mov"
    
    var locationInfo = LocationInfo()
    let locationManager = CLLocationManager()
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹                           📹📹📹****/
        /****📹📹📹📹  BEGIN SETTING UP CAMERA  📹📹📹****/
        /****📹📹📹📹                           📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/

        previewView = UIView()
        previewView.frame = view.layer.frame
        view.addSubview(previewView)
        
        recorder = SCRecorder.sharedRecorder()
        
        // Start running the flow of buffers
//        if recorder.startRunning() {
//            print("recorder error: \(recorder.error)")
//        }
        
        // Create a new session and set it to the recorder
//        recordSession = SCRecordSession()
//        recorder.session = recordSession
        

        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.mirrorOnFrontCamera = true
        //recorder.keepMirroringOnWrite = true
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let frontCamera = (userDefaults.valueForKey("frontCamera") as? Bool) ?? false
        recorder.device = frontCamera ? .Front : .Back
        
        //_recorder.maxRecordDuration = CMTimeMake(10, 1);
        //_recorder.fastRecordMethodEnabled = YES;
        
        recorder.delegate = self
        recorder.autoSetVideoOrientation = false
        recorder.previewView = previewView
        
        //self.retakeButton.addTarget(self, action: #selector(self.handleRetakeButtonTapped), forControlEvents: .TouchUpInside)
        //self.stopButton.addTarget(self, action: #selector(self.handleStopButtonTapped), forControlEvents: .TouchUpInside)
        //self.reverseCamera.addTarget(self, action: #selector(self.handleReverseCameraTapped), forControlEvents: .TouchUpInside)
        
        
        //self.focusView = SCRecorderToolsView(frame: previewView.bounds)
        //self.focusView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        //self.focusView.recorder = recorder
        //previewView.addSubview(self.focusView)
        //self.focusView.outsideFocusTargetImage = UIImage(named: "capture_flip")!
        //self.focusView.insideFocusTargetImage = UIImage(named: "capture_flip")!
        
        self.recorder.initializeSessionLazily = false

        do{
            try recorder.prepare()
        } catch {
            print("Prepare error: \(error)")
        }
        
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/
        /****📹📹📹📹📹📹📹📹📹📹📹📹📹📹📹****/

        
        // Begin setting location
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        /// End location
        
        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//        }
//        catch {
//            print(error)
//        }
//        
//        do{
//            captureSession.beginConfiguration()
//            
//            // Preset the session for taking photo in full resolution
//            captureSession.sessionPreset = AVCaptureSessionPresetHigh
//            
//            audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
//            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
//            captureSession.addInput(audioInput)
//            
//            let userDefaults = NSUserDefaults.standardUserDefaults()
//            let frontCamera = (userDefaults.valueForKey("frontCamera") as? Bool) ?? false
//            let devicePosition : AVCaptureDevicePosition = frontCamera ? .Front : .Back
//            
//            // Get the available devices that is capable of taking video
//            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
//            for device in devices {
//                if device.position == devicePosition {
//                    videoDevice = device
//                }
//            }
//            
//            videoInput = try AVCaptureDeviceInput(device: videoDevice)
//            captureSession.addInput(videoInput)
//            
//            // Configure the session with the output for capturing video
//            videoFileOutput = AVCaptureMovieFileOutput()
//            captureSession.addOutput(videoFileOutput)
//            
//            if let connection = videoFileOutput?.connectionWithMediaType(AVMediaTypeVideo) {
//                connection.enabled = true
//                if connection.supportsVideoOrientation {
//                    print(".Portrait")
//                    connection.videoOrientation = .Portrait
//                }
//                if connection.supportsVideoMirroring {
//                    print(".FrontCamera")
//                    connection.videoMirrored = frontCamera
//                }
//                if connection.supportsVideoStabilization {
//                    print(".VideoStabilization")
//                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
//                }
//            }
//            
//            captureSession.commitConfiguration()
//        }
//        catch {
//            print(error)
//        }
        
        
//        // Provide a camera preview
//        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(cameraPreviewLayer!)
//        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
//        cameraPreviewLayer?.frame = view.frame
//        cameraPreviewLayer?.connection.videoOrientation = .Portrait
        
        
        // set up recorder button
        recordButton = RecordButton(frame: CGRectMake(0,0,80,80))
        recordButton.center = self.view.center
        recordButton.progressColor = .redColor()
        recordButton.buttonColor = UIColor(white: 1, alpha: 0.5)
        recordButton.closeWhenFinished = false
        
        //recordButton.addTarget(self, action: #selector(record), forControlEvents: .TouchDown)
        //recordButton.addTarget(self, action: #selector(stop), forControlEvents: .TouchUpInside)

        recordButton.addGestureRecognizer(SCTouchDetector(target: self, action: #selector(self.handleTouchDetected)))
        
        view.addSubview(recordButton)
        self.view.addSubview(recordButton)
        recordButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-30)
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
        
        // Bring the record button to front
//        view.bringSubviewToFront(recordButton)
//        view.bringSubviewToFront(flipButton)
//        view.bringSubviewToFront(backButton)
    
    }
    
    func recorder(recorder: SCRecorder, didSkipVideoSampleBufferInSession recordSession: SCRecordSession) {
        print("Skipped video buffer")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        print("Reconfigured audio input: \(audioInputError)")
    }
    
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        print("Reconfigured video input: \(videoInputError)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let recordSession = recorder.session {
            self.recorder.session = nil
            recordSession.cancelSession(nil)
        }
        self.prepareSession()
        recorder.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        recorder.startRunning()
//    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.stopRunning()
    }
    
    // #pragma mark - Handle
    
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
    
    func handleStopButtonTapped() {
        recorder.pause {
            self.isRecording = false
            self.progress = 0
            self.recordButton.buttonState = .Idle
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
        self.updateTimeRecordedLabel()
    }
    
    func recorder(recorder: SCRecorder, didCompleteSession recordSession: SCRecordSession) {
        print("didCompleteSession:")
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
        if error == nil {
            print("Initialized video in record session")
        }
        else {
            print("Failed to initialize video in record session: \(error!.localizedDescription)")
        }
    }
    
    func recorder(recorder: SCRecorder, didBeginSegmentInSession recordSession: SCRecordSession, error: NSError?) {
        print("Began record segment: \(error)")
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession recordSession: SCRecordSession, error: NSError?) {
        print("Completed record segment at \(segment?.url): \(error) (frameRate: \(segment?.frameRate))")
    }
    
    func handleTouchDetected(touchDetector: SCTouchDetector) {
        if touchDetector.state == .Began {
            
            isRecording = true
            
            recorder.record()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
        else if touchDetector.state == .Ended {
            handleStopButtonTapped()
            //recorder.pause()
        }
    }
    
    func updateTimeRecordedLabel() {
        
        var currentTime = kCMTimeZero
        if recorder.session != nil {
            currentTime = recorder.session!.duration
        }
        //self.timeRecordedLabel.text! = String(format: "%.2f sec", CMTimeGetSeconds(currentTime))
        
        let seconds = CMTimeGetSeconds(currentTime)
        
        print(seconds)

        progress = CGFloat(seconds) / maxDuration
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            handleStopButtonTapped()
        }
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession recordSession: SCRecordSession) {
        self.updateTimeRecordedLabel()
    }
    
    
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    /*** 🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺🍺 ***/
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        locationManager.stopUpdatingLocation()
        locationInfo.load(location)
    }
    
    func close(){
//        stop()
        handleStopButtonTapped()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func flipCamera(){
        
        recorder.switchCaptureDevices()

//        captureSession.stopRunning()
//        
//        do {
//            
//            captureSession.beginConfiguration()
//            captureSession.sessionPreset = AVCaptureSessionPresetHigh
//            
//            for input in captureSession.inputs {
//                captureSession.removeInput(input as! AVCaptureInput)
//            }
//            
//            audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
//            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
//            captureSession.addInput(audioInput)
//            
//            let position = (videoInput?.device.position == AVCaptureDevicePosition.Front) ? AVCaptureDevicePosition.Back : AVCaptureDevicePosition.Front
//            let frontCamera = position == .Front
//            
//            let userDefaults = NSUserDefaults.standardUserDefaults()
//            userDefaults.setValue(frontCamera, forKey: "frontCamera")
//            //userDefaults.synchronize()
//            
//            for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
//                
//                if let device = device as? AVCaptureDevice where device.position == position {
//                    
//                    videoInput = try AVCaptureDeviceInput(device: device)
//                    captureSession.addInput(videoInput)
//                }
//            }
//            
//            if let connection = videoFileOutput?.connectionWithMediaType(AVMediaTypeVideo) {
//                connection.enabled = true
//                if connection.supportsVideoOrientation {
//                    print(".Portrait")
//                    connection.videoOrientation = .Portrait
//                }
//                if connection.supportsVideoMirroring {
//                    print(".FrontCamera")
//                    connection.videoMirrored = frontCamera
//                }
//                if connection.supportsVideoStabilization {
//                    print(".VideoStabilization")
//                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
//                }
//            }
//            
//            captureSession.commitConfiguration()
//            
//        } catch {
//            print(error)
//        }
//        
//        captureSession.startRunning()
    }
    
//    func record() {
//        
////        if !isRecording {
////            
////            // Start recording
////            isRecording = true
////            
////            //recordButtonTapped()
////            
////            let outputFileURL = NSURL(fileURLWithPath: self.outputPath)
////            
////            if let connection = videoFileOutput?.connectionWithMediaType(AVMediaTypeVideo) {
////                if connection.supportsVideoOrientation {
////                    print(".Portrait")
////                    connection.videoOrientation = .Portrait
////                }
////                if connection.supportsVideoStabilization {
////                    print(".VideoStabilization")
////                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
////                }
////            }
////            
////            videoFileOutput?.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
////            
////            if CLLocationManager.locationServicesEnabled() {
////                locationManager.startUpdatingLocation()
////            }
////        }
//        
////        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
//    }
    
//    func updateProgress() {
//        progress = progress + (CGFloat(0.05) / maxDuration)
//        recordButton.setProgress(progress)
//        if progress >= 1 {
//            stop()
//            recorder.pause()
//            handleStopButtonTapped()
//            recordButton.buttonState = .Idle
//        }
//    }
//    
//    func pause(){
////        cameraManager.pauseRecordingVideo()
//        recorder.pause()
//        progressTimer?.invalidate()
//        isRecording = false
//    }
//    
//    func stop() {
//        if (isRecording){
//            isRecording = false
//            //videoFileOutput?.stopRecording()
//            self.progressTimer?.invalidate()
//            self.progress = 0
//            recordButton.buttonState = .Idle
////            cameraManager.stopRecordingVideo(stopRecordingHandler)
//        }
//    }
    
//    func stopRecordingHandler(videoURL: NSURL?, error: NSError?, localIdentifier: LocalIdentifierType?){
//        if let err = error {
//            print("Error \(err)")
//        }
//        else {
//            
//            if let url = videoURL {
//                
//                print("Saved video from local url \(url) with uuid \(localIdentifier)")
//                
//                let data = NSData(contentsOfURL: url)!
//                
//                print("Byte Size Before Compression: \(data.length / 1024) KB")
//                
//                let outputURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + UploadHelper.sharedInstance.fileName)
//                
//                // The compress file extension will depend on the output file type
//                self.helper.compressVideo(url, outputURL: outputURL, outputFileType: AVFileTypeMPEG4, handler: { session in
//                    
//                    if let currSession = session {
//                        
//                        print("Progress: \(currSession.progress)")
//                        
//                        print("Save to \(currSession.outputURL)")
//                        
//                        if currSession.status == .Completed {
//                            
//                            if let data = NSData(contentsOfURL: currSession.outputURL!) {
//                                
//                                print("File size after compression: \(data.length / 1024) KB")
//                                
//                                // Play compressed video
//                                dispatch_async(dispatch_get_main_queue(), {
//                                    
//                                    let preview = CameraPreviewController()
//                                    preview.locationInfo = self.locationInfo
//                                    self.presentViewController(preview, animated: true, completion: nil)
//                                    
//                                    //                                        let player  = AVPlayer(URL: currSession.outputURL!)
//                                    //                                        let layer   = AVPlayerLayer(player: player)
//                                    //                                        layer.frame = self.view.bounds
//                                    //                                        self.view.layer.addSublayer(layer)
//                                    //                                        player.play()
//                                    //
//                                    //                                        print("Playing video...")
//                                })
//                            }
//                        }
//                        else if currSession.status == .Failed {
//                            print(" There was a problem compressing the video: \(currSession.error!.localizedDescription)")
//                        }
//                    }
//                })
//            }
//        }
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        cameraManager.resumeCaptureSession()
//        
////        captureSession.startRunning()
//        
//        locationManager.startUpdatingLocation()
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
////        cameraManager.stopCaptureSession()
//        
////        stop()
//        
////        captureSession.stopRunning()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate methods
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        if error != nil {
            print(error)
            return
        }
        
        print("Video Captured")
        
        print("Byte Size Before Compression: \(captureOutput.recordedFileSize / 1024) KB")
        
        print(outputFileURL)
        
        let inputUrl = NSURL(fileURLWithPath: outputPath)
        let outputURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + UploadHelper.sharedInstance.fileName)
        
        convertVideoWithMediumQuality(inputUrl, outputURL: outputURL) {
            let preview = CameraPreviewController()
            preview.locationInfo = self.locationInfo
            self.presentViewController(preview, animated: true, completion: nil)
        }
    }
    
    func export() {
        let inputURL = NSURL(fileURLWithPath: outputPath)
        let outputURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + UploadHelper.sharedInstance.fileName)
        
        VideoHelper.sharedInstance.export(inputURL, outputURL: outputURL) {
            let preview = CameraPreviewController()
            preview.locationInfo = self.locationInfo
            self.presentViewController(preview, animated: true, completion: nil)
            
            // Save pin to Photo
            let library = ALAssetsLibrary()
            library.writeVideoAtPathToSavedPhotosAlbum(inputURL, completionBlock: { (assetURL, error) in
                if error != nil {
                    print(error)
                    return
                }
                print(assetURL)
            })
            
            // Save pin to Photo
            //let library = ALAssetsLibrary()
            library.writeVideoAtPathToSavedPhotosAlbum(outputURL, completionBlock: { (assetURL, error) in
                if error != nil {
                    print(error)
                    return
                }
                print(assetURL)
            })
        }
    }
    
    func convertVideoWithMediumQuality(inputURL : NSURL, outputURL: NSURL, completion: ()->()){
        
        print("Compressing...")
        
        // Delete file if existed
        let filePath = outputURL.path!;
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch {
                print(error)
            }
        }
        
        let asset = AVURLAsset(URL: inputURL, options: nil)
        
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronouslyWithCompletionHandler {
            switch exportSession.status {
            case .Completed:
                print("export completed")
                dispatch_async(dispatch_get_main_queue(), {
                    completion()
                })
            case  .Failed:
                print("export failed \(exportSession.error)")
            case .Cancelled:
                print("export cancelled \(exportSession.error)")
            default:
                print("default")
            }
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

import UIKit.UIGestureRecognizerSubclass

class SCTouchDetector : UIGestureRecognizer {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.enabled {
            self.state = .Began
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.enabled {
            self.state = .Ended
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.enabled {
            self.state = .Ended
        }
    }
}
