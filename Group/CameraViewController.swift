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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    var recordButton:RecordButton!
    var progressTimer : Timer!
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
    
    var locationInfo = LocationInfo()
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
            
            // Preset the session for full resolution
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            captureSession.addInput(audioInput)
            
            let userDefaults = UserDefaults.standard
            let frontCamera = (userDefaults.value(forKey: "frontCamera") as? Bool) ?? false
            let devicePosition : AVCaptureDevicePosition = frontCamera ? .front : .back
            
            // Get the available devices that is capable of taking video
            let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
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
            
            if let connection = videoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
                connection.isEnabled = true
                if connection.isVideoOrientationSupported {
                    print(".Portrait")
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    print(".FrontCamera")
                    connection.isVideoMirrored = frontCamera
                }
                if connection.isVideoStabilizationSupported {
                    print(".VideoStabilization")
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
            }
            
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
        cameraPreviewLayer?.connection.videoOrientation = .portrait
        
        // set up recorder button
        recordButton = RecordButton(frame: CGRect(x: 0,y: 0,width: 80,height: 80))
        recordButton.center = self.view.center
        recordButton.progressColor = .red
        recordButton.buttonColor = UIColor(white: 1, alpha: 0.5)
        recordButton.closeWhenFinished = false
        recordButton.addTarget(self, action: #selector(record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        view.addSubview(recordButton)
        self.view.addSubview(recordButton)
        recordButton.snp_makeConstraints { [weak self] (make) -> Void in
            make.bottom.equalTo(self!.view).offset(-30)
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
        flipButton.snp_makeConstraints { [weak self] (make) -> Void in
            make.top.equalTo(self!.view).offset(15)
            make.right.equalTo(self!.view).offset(-18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        let backIcon = UIImage(named: "ic_close") as UIImage?
        let backButton = UIButton(type: .system)
        backButton.tintColor = UIColor(white: 1, alpha: 0.5)
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(backIcon, for: UIControlState())
        backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp_makeConstraints { [weak self] (make) -> Void in
            make.top.equalTo(self!.view).offset(15)
            make.left.equalTo(self!.view).offset(18)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        // Bring the record button to front
        view.bringSubview(toFront: recordButton)
        view.bringSubview(toFront: flipButton)
        view.bringSubview(toFront: backButton)
        
        captureSession.startRunning()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        locationManager.stopUpdatingLocation()
        locationInfo.load(location)
    }
    
    func convertVideoWithMediumQuality(_ inputURL : URL, outputURL: URL, completion: @escaping ()->()){
        
        print("Compressing...")
        
        // Delete file if existed
        let filePath = outputURL.path;
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                print(error)
            }
        }
        
        let asset = AVURLAsset(url: inputURL, options: nil)
        
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously {            
            switch exportSession.status {
            case .completed:
                print("export completed")
                DispatchQueue.main.async(execute: {
                    completion()
                })
            case  .failed:
                print("export failed \(exportSession.error)")
            case .cancelled:
                print("export cancelled \(exportSession.error)")
            default:
                print("default")
            }
        }
    }
    
    func close(){
        stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    func flipCamera(){
        
        captureSession.stopRunning()
        
        do {
            
            captureSession.beginConfiguration()
            
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            for input in captureSession.inputs {
                captureSession.removeInput(input as! AVCaptureInput)
            }
            
            audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            captureSession.addInput(audioInput)
            
            let position = (videoInput?.device.position == AVCaptureDevicePosition.front) ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front
            let frontCamera = position == .front
            
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(frontCamera, forKey: "frontCamera")
            //userDefaults.synchronize()
            
            for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                
                if let device = device as? AVCaptureDevice, device.position == position {
                    
                    videoInput = try AVCaptureDeviceInput(device: device)
                    captureSession.addInput(videoInput)
                }
            }
            
            if let connection = videoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
                connection.isEnabled = true
                if connection.isVideoOrientationSupported {
                    print(".Portrait")
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    print(".FrontCamera")
                    connection.isVideoMirrored = frontCamera
                }
                if connection.isVideoStabilizationSupported {
                    print(".VideoStabilization")
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
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
            let outputFileURL = URL(fileURLWithPath: self.outputPath)
            
            if let connection = videoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
                if connection.isVideoOrientationSupported {
                    print(".Portrait")
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoStabilizationSupported {
                    print(".VideoStabilization")
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
            }
            
            videoFileOutput?.startRecording(toOutputFileURL: outputFileURL, recordingDelegate: self)
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func updateProgress() {
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress >= 1 {
            stop()
            recordButton.buttonState = .idle
        }
    }
    
    func stop() {
        if (isRecording){
            isRecording = false
            videoFileOutput?.stopRecording()
            self.progressTimer?.invalidate()
            self.progress = 0
            recordButton.buttonState = .idle
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
        captureSession.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate methods
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        print("Video Captured")
        
        print("Byte Size Before Compression: \(captureOutput.recordedFileSize / 1024) KB")
        
        print(outputFileURL)

        let inputUrl = outputFileURL
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UploadHelper.sharedInstance.fileName)
        
        convertVideoWithMediumQuality(inputUrl!, outputURL: outputURL) {
            let preview = CameraPreviewController()
            preview.locationInfo = self.locationInfo
            self.present(preview, animated: true, completion: nil)
        }

    }
    
    func export() {
        let inputURL = URL(fileURLWithPath: outputPath)
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UploadHelper.sharedInstance.fileName)
        
        VideoHelper.sharedInstance.export(inputURL, outputURL: outputURL) {
            let preview = CameraPreviewController()
            preview.locationInfo = self.locationInfo
            self.present(preview, animated: true, completion: nil)
            
            // Save pin to Photo
            let library = ALAssetsLibrary()
            library.writeVideoAtPath(toSavedPhotosAlbum: inputURL, completionBlock: { (assetURL, error) in
                if error != nil {
                    print(error)
                    return
                }
                print(assetURL)
            })
            
            // Save pin to Photo
            //let library = ALAssetsLibrary()
            library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { (assetURL, error) in
                if error != nil {
                    print(error)
                    return
                }
                print(assetURL)
            })
        }
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
