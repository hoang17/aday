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
import FirebaseStorage
import FirebaseAuth
import DigitsKit
import SnapKit
import MapKit
import AssetsLibrary

class CameraPreviewController: AVPlayerViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    let textField = UITextField()
    let locationField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var outputFileURL:NSURL?
    var fileName: String!
    var gotLo = false
    var lo = Location()

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Begin setting location
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        /// End location

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
        
        let nextIcon = UIImage(named: "ic_blue_arrow") as UIImage?
        let doneButton = UIButton(type: .System)
        doneButton.tintColor = UIColor(white: 1, alpha: 1)
        doneButton.backgroundColor = UIColor.clearColor()
        doneButton.setImage(nextIcon, forState: .Normal)
        doneButton.addTarget(self, action: #selector(doneRecording), forControlEvents: .TouchUpInside)
        self.view.addSubview(doneButton)
        self.view.bringSubviewToFront(doneButton)
        doneButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.right.equalTo(self.view).offset(-20)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        
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
        
        locationField.origin = CGPoint(x: 0, y: 0)
        locationField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        locationField.textColor = UIColor(white: 1, alpha: 0.6)
        locationField.font = UIFont.systemFontOfSize(12.0)
        locationField.textAlignment = NSTextAlignment.Center
        locationField.height = 20
        locationField.width = UIScreen.mainScreen().bounds.width
        locationField.hidden = true
        locationField.returnKeyType = UIReturnKeyType.Done
        locationField.delegate = self
        
        view.addSubview(locationField)
        view.bringSubviewToFront(locationField)
 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)

        let pan = UIPanGestureRecognizer(target:self, action:#selector(panGesture))
        textField.addGestureRecognizer(pan)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.gotLo {
            return
        }
        
        self.gotLo = true
        
        let co = manager.location!.coordinate
        
        manager.stopUpdatingLocation()
        
        self.lo.latitude = co.latitude
        self.lo.longitude = co.longitude
        
        print("locations = \(co.latitude) \(co.longitude)")
        
        let geoCoder = CLGeocoder()
        
        if let location = manager.location {
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                let placeMark: CLPlacemark! = placemarks?[0]
                if (placeMark == nil){
                    return
                }
                
                // Address dictionary
                let name = placeMark.addressDictionary!["Name"] as! String
                let city = placeMark.addressDictionary!["City"] as! String
                let country = placeMark.addressDictionary!["CountryCode"] as! String
                let sublocal = placeMark.addressDictionary!["SubLocality"] as! String
                let subarea = placeMark.addressDictionary!["SubAdministrativeArea"] as! String
                
                print(name)
                // print(placeMark.addressDictionary)
                
                self.lo.name = name
                self.lo.city = city
                self.lo.country = country
                self.lo.sublocal = sublocal
                self.lo.subarea = subarea
                self.locationField.text = name
                self.locationField.hidden = true
                
            })
        }
        
        
    }
    
    func doneRecording() {
        self.back()
        upload()
    }
    
    // Upload file
    func upload(){
        
        let uid : String = (FIRAuth.auth()?.currentUser?.uid)!
        let uploadFile = "\(uid)_\(arc4random()%1000000).mp4"
        
        print("Uploading \(uploadFile)...")
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        gs.child("clips/" + uploadFile).putFile(outputFileURL!, metadata: metadata) { metadata, error in
            // upload done
            if (error != nil) {
                print(error)
            } else {
                print("Clip uploaded to " + (metadata!.downloadURL()?.absoluteString)!)
                
                // Generate thumb image
                do {
                    let asset = AVURLAsset(URL: NSURL(fileURLWithPath: NSTemporaryDirectory() + self.fileName), options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
                    let uiimg = UIImage(CGImage: cgimg)
                    let data = UIImageJPEGRepresentation(uiimg, 0.5)
                    let filePath = NSTemporaryDirectory() + self.fileName + ".jpg"
                    
                    if data!.writeToFile(filePath, atomically: true) {
                        // Upload thumb image
                        let thumb = uploadFile + ".jpg"
                        let fileUrl = NSURL(fileURLWithPath: filePath)
                        metadata!.contentType = "image/jpg"
                        gs.child("thumbs/" + thumb).putFile(fileUrl, metadata: metadata) { metadata, error in
                            // upload done
                            if (error != nil) {
                                print(error)
                            } else {
                                print("Thumb uploaded to " + (metadata!.downloadURL()?.absoluteString)!)
                                
                                // Save clip to db
                                let ref = FIRDatabase.database().reference()
                                let id = ref.child("clips").childByAutoId().key
                                let uid : String = FIRAuth.auth()!.currentUser!.uid
                                let fname = uploadFile
                                let txt = self.textField.text
                                let y = self.textLocation.y/self.view.frame.height
                                let clip = Clip(id: id, uid: uid, fname: fname, txt: txt!, y: y, location: self.lo, thumb: (metadata!.downloadURL()?.absoluteString)!)
                                
                                // Create new clip at /users/$userid/clips/$clipid
                                let update = [
                                    "/users/\(uid)/clips/\(id)/": clip.toAnyObject(),
                                    "/users/\(uid)/uploaded":clip.date]
                                ref.updateChildValues(update)

                                // Create new clip at /clips/$clipid
                                ref.child("clips").child(id).setValue(clip.toAnyObject())
                                
                                print("Clip is saved to db \(id)")
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
                
            }
        }
        
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
        
        locationField.resignFirstResponder()
        
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
    
}

