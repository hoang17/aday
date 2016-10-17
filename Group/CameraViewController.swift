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

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    var recordButton:RecordButton!
    var progressTimer : NSTimer!
    var progress : CGFloat! = 0
    
    // Max duration of the recordButton
    let maxDuration: CGFloat! = 10
    
    let captureSession = AVCaptureSession()
    var videoDevice:AVCaptureDevice?
    var audioDevice:AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var videoFileOutput:AVCaptureMovieFileOutput?
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    let outputPath = NSTemporaryDirectory() + "output.mov"
    
    var lo = Location()
    let locationManager = CLLocationManager()
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Begin setting location
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        /// End location
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        }
        catch {
            print(error)
        }
        
        do{
            captureSession.beginConfiguration()
            
            // Preset the session for taking photo in full resolution
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            captureSession.addInput(audioInput)
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let frontCamera = (userDefaults.valueForKey("frontCamera") as? Bool) ?? false
            let devicePosition : AVCaptureDevicePosition = frontCamera ? .Front : .Back
            
            // Get the available devices that is capable of taking video
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
            for device in devices {
                if device.position == devicePosition {
                    videoDevice = device
                }
            }
            
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(videoInput)
            
            // Configure the session with the output for capturing video
            videoFileOutput = AVCaptureMovieFileOutput()
            captureSession.addOutput(videoFileOutput)
            
            captureSession.commitConfiguration()
        }
        catch {
            print(error)
        }
        
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        
        // set up recorder button
        recordButton = RecordButton(frame: CGRectMake(0,0,80,80))
        recordButton.center = self.view.center
        recordButton.progressColor = .redColor()
        recordButton.buttonColor = UIColor(white: 1, alpha: 0.5)
        recordButton.closeWhenFinished = false
        recordButton.addTarget(self, action: #selector(record), forControlEvents: .TouchDown)
        recordButton.addTarget(self, action: #selector(stop), forControlEvents: UIControlEvents.TouchUpInside)
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
            make.width.equalTo(26)
            make.height.equalTo(26)
        }
        
        let backIcon = UIImage(named: "ic_close") as UIImage?
        let backButton = UIButton(type: .System)
        backButton.tintColor = UIColor(white: 1, alpha: 0.5)
        backButton.backgroundColor = UIColor.clearColor()
        backButton.setImage(backIcon, forState: .Normal)
        backButton.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        backButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(15)
            make.left.equalTo(self.view).offset(18)
            make.width.equalTo(26)
            make.height.equalTo(26)
        }
        
        // Bring the record button to front
        view.bringSubviewToFront(recordButton)
        view.bringSubviewToFront(flipButton)
        view.bringSubviewToFront(backButton)
        
        captureSession.startRunning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func didBecomeActive() {
        if view.window != nil && CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        if let location = manager.location {

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                self.lo = Location()
                self.lo.latitude = location.coordinate.latitude
                self.lo.longitude = location.coordinate.longitude
                
                // print("locations = \(lo.latitude) \(lo.longitude)")
                
                if let placeMark = placemarks?.first {
                    // Address dictionary
                    let name = placeMark.addressDictionary!["Name"] as? String ?? ""
                    let city = placeMark.addressDictionary!["City"] as? String ?? ""
                    let country = placeMark.addressDictionary!["CountryCode"] as? String ?? ""
                    let sublocal = placeMark.addressDictionary!["SubLocality"] as? String ?? ""
                    let subarea = placeMark.addressDictionary!["SubAdministrativeArea"] as? String ?? ""
                    
                    // print(name)
                    // print(placeMark.addressDictionary)
                    
                    self.lo.name = name
                    self.lo.city = city
                    self.lo.country = country
                    self.lo.sublocal = sublocal
                    self.lo.subarea = subarea
                }
            })
        }
    }
    
    func convertVideoWithMediumQuality(inputURL : NSURL){
        
        print("Compressing...")
        
        let fileName = UploadHelper.sharedInstance.fileName
        
        let savePath = NSURL(fileURLWithPath: NSTemporaryDirectory() + fileName).absoluteString
        
        // Delete file if existed
        let filePath = NSTemporaryDirectory() + fileName;
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch {
                print(error)
            }
        }
        
        let savePathUrl = NSURL(string: savePath!)
        let asset = AVURLAsset(URL: inputURL, options: nil)
        
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = savePathUrl
        exportSession.exportAsynchronouslyWithCompletionHandler {            
            switch exportSession.status {
            case .Completed:
                print("export completed")
                dispatch_async(dispatch_get_main_queue(), {
                    let preview = CameraPreviewController()
                    preview.lo = self.lo
                    self.presentViewController(preview, animated: true, completion: nil)
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
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func flipCamera(){
        
        captureSession.stopRunning()
        
        do {
            
            captureSession.beginConfiguration()
            
            for input in captureSession.inputs {
                captureSession.removeInput(input as! AVCaptureInput)
            }
            
            audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            captureSession.addInput(audioInput)
            
            let position = (videoInput?.device.position == AVCaptureDevicePosition.Front) ? AVCaptureDevicePosition.Back : AVCaptureDevicePosition.Front
            let frontCamera = position == .Front
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(frontCamera, forKey: "frontCamera")
            // userDefaults.synchronize()
            
            for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
                
                if let device = device as? AVCaptureDevice where device.position == position {
                    
                    videoInput = try AVCaptureDeviceInput(device: device)
                    captureSession.addInput(videoInput)
                    
                }
            }
            
            captureSession.commitConfiguration()
            
            
        } catch {
            print(error)
        }
        
        captureSession.startRunning()
        
    }
    
    func record() {
        
        if !isRecording {
            // Start recording
            isRecording = true
            let outputFileURL = NSURL(fileURLWithPath: self.outputPath)
            videoFileOutput?.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
            
            if view.window != nil && CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func updateProgress() {
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress >= 1 {
            stop()
            recordButton.buttonState = .Idle
        }
    }
    
    func stop() {
        if (isRecording){
            isRecording = false
            videoFileOutput?.stopRecording()
            self.progressTimer.invalidate()
            self.progress = 0
        }
    }
    
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
        
        print(captureOutput.recordedFileSize)
        print(outputFileURL)

        let outputFileURL = NSURL(fileURLWithPath: self.outputPath)
        self.convertVideoWithMediumQuality(outputFileURL)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
