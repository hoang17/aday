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

class CameraPreviewController: AVPlayerViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    let textField = UITextField()
    let locationField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var outputFileURL:NSURL?
    var fileName = "output.mp4"
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
        doneButton.addTarget(self, action: #selector(upload), forControlEvents: .TouchUpInside)
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
        
        locationField.origin = CGPoint(x: 0, y: 0.8 * UIScreen.mainScreen().bounds.height)
        locationField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        locationField.textColor = UIColor.whiteColor()
        locationField.font = UIFont.systemFontOfSize(14.0)
        locationField.textAlignment = NSTextAlignment.Center
        locationField.height = 32
        locationField.width = UIScreen.mainScreen().bounds.width
        locationField.hidden = true
        
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
        
        self.lo.latitude = co.latitude
        self.lo.longitude = co.longitude
        
        print("locations = \(co.latitude) \(co.longitude)")
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: co.latitude, longitude: co.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            let locationName = placeMark.addressDictionary!["Name"] as! NSString
            let city = placeMark.addressDictionary!["City"] as! NSString
            let country = placeMark.addressDictionary!["Country"] as! NSString
            
            self.lo.name = "\(locationName), \(city), \(country)"
            
            self.locationField.text = self.lo.name
            self.locationField.hidden = false
            
        })
        
    }
    
    // Upload file
    func upload(){
        
        self.back()
        
        var number = Digits.sharedInstance().session()!.phoneNumber
        number.removeAtIndex(number.startIndex)
        let uploadFile = "\(number)_\(arc4random()%1000000).mp4"
        
        print("Uploading \(uploadFile)...")
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        gs.child(uploadFile).putFile(outputFileURL!, metadata: metadata) { metadata, error in
            // upload done
            if (error != nil) {
                print(error)
            } else {
                print("File uploaded to " + (metadata!.downloadURL()?.absoluteString)!)
                
                // Save clip to db
                let ref = FIRDatabase.database().reference().child("clips")
                let id = ref.childByAutoId().key
                let uid = FIRAuth.auth()?.currentUser?.uid
                let fname = uploadFile
                let txt = self.textField.text
                let y = self.textLocation.y/self.view.frame.height
                let clip = Clip(id: id, uid: uid!, fname: fname, txt: txt!, y: y, location: self.lo)
                ref.child(id).setValue(clip.toAnyObject())
                
                print("Clip is saved to db \(id)")
                
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

