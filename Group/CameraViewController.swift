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

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var cameraButton:UIButton!
    
    let captureSession = AVCaptureSession()
    var currentDevice:AVCaptureDevice?
    var videoFileOutput:AVCaptureMovieFileOutput?
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Get the available devices that is capable of taking video
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        // Get the back-facing camera for taking videos
        for device in devices {
            if device.position == AVCaptureDevicePosition.Front {
                currentDevice = device
            }
        }
        
        let captureDeviceInput:AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
        } catch {
            print(error)
            return
        }
        
        // Configure the session with the output for capturing video
        videoFileOutput = AVCaptureMovieFileOutput()
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        cameraButton = UIButton(type: .System)
        cameraButton.backgroundColor = UIColor.redColor()
        cameraButton.layer.cornerRadius = 40
        cameraButton.addTarget(self, action: #selector(capture), forControlEvents: .TouchUpInside)
        self.view.addSubview(cameraButton)
        cameraButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-50)
            make.centerX.equalTo(self.view)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        // Bring the camera button to front
        view.bringSubviewToFront(cameraButton)
        captureSession.startRunning()
        
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
        
        print("video captured")
        
        let cameraPreview = CameraPreviewController()
        self.presentViewController(cameraPreview, animated: true, completion: nil)
    }
    
    // MARK: - Segue methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playVideo" {
            let videoPlayerViewController = segue.destinationViewController as! AVPlayerViewController
            let videoFileURL = sender as! NSURL
            videoPlayerViewController.player = AVPlayer(URL: videoFileURL)
        }
    }
    
    
    // MARK: - Action methods
    
//    @IBAction func unwindToCamera(segue:UIStoryboardSegue) {
//        
//    }
    
    func capture() {
        if !isRecording {
            isRecording = true
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransformMakeScale(0.8, 0.8)
                }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = NSURL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
            
        } else {
            
            isRecording = false
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: [], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: nil)
            //            cameraButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
            
            
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}

    