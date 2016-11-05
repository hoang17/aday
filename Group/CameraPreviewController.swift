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

class CameraPreviewController: AVPlayerViewController, UITextFieldDelegate {

    let textField = UITextField()
    var textLocation: CGPoint = CGPoint(x: 0, y: 0)
    var locationInfo: LocationInfo?
    
    // let locationField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset = AVAsset(url: UploadHelper.sharedInstance.fileUrl as URL)
        self.showsPlaybackControls = false
        self.player = AVPlayer(playerItem: AVPlayerItem(asset:asset))
        self.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.player!.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
        
        self.player?.play()
        
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField.textColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.textAlignment = NSTextAlignment.center
        textField.text = ""
        textField.isHidden = true
        textField.height = 34
        textField.width = UIScreen.main.bounds.width
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyType.done
        textField.isUserInteractionEnabled = true
        
        view.addSubview(textField)
        view.bringSubview(toFront: textField)
        
        
        let backIcon = UIImage(named: "ic_close") as UIImage?
        let backButton = UIButton(type: .system)
        backButton.tintColor = UIColor(white: 1, alpha: 0.5)
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(backIcon, for: UIControlState())
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
        backButton.snp_makeConstraints { [weak self] (make) in
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
        self.view.bringSubview(toFront: doneButton)
        doneButton.snp_makeConstraints { [weak self] (make) in
            make.bottom.equalTo(self!.view).offset(-20)
            make.right.equalTo(self!.view).offset(-20)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        
//        locationField.origin = CGPoint(x: 0, y: 0)
//        locationField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
//        locationField.textColor = UIColor(white: 1, alpha: 0.6)
//        locationField.font = UIFont.systemFontOfSize(12.0)
//        locationField.textAlignment = NSTextAlignment.Center
//        locationField.height = 20
//        locationField.width = UIScreen.mainScreen().bounds.width
//        locationField.hidden = true
//        locationField.returnKeyType = UIReturnKeyType.Done
//        locationField.delegate = self
//        view.addSubview(locationField)
//        view.bringSubviewToFront(locationField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        let pan = UIPanGestureRecognizer(target:self, action:#selector(panGesture))
        textField.addGestureRecognizer(pan)
    }
    
    func submit() {
        
        let id = FIRDatabase.database().reference().child("clips").childByAutoId().key
        let uid = AppDelegate.uid
        let uname = AppDelegate.name
        let txt = self.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let y = self.textLocation.y/self.view.frame.height
        let uploadFile = "\(id).mp4"
        
        let clip = ClipModel(id: id, uid: uid!, uname: uname!, fname: uploadFile, txt: txt!, y: y, locationInfo: locationInfo!)
        
        UploadHelper.sharedInstance.enqueueUpload(clip, liloaded: locationInfo!.loaded)
        
        self.back()
    }
    
    // Limit text length to textfield width
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let combinedString = textField.attributedText!.mutableCopy() as! NSMutableAttributedString
        combinedString.replaceCharacters(in: range, with: string)
        return combinedString.size().width < textField.bounds.size.width-10
        
    }
    
    // On return done editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text == ""){
            textField.isHidden = true
        } else {
            UIView.animate(withDuration: 0.2, animations: { self.textField.center.y = self.textLocation.y }, completion: nil)
        }
        return true
    }
    
    // Allow dragging textfield
    func panGesture(_ sender:UIPanGestureRecognizer) {
        let translation  = sender.translation(in: self.view)
        textLocation = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y + translation.y)
        sender.view!.center = textLocation
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    // Move textfield ontop of keyboard
    func keyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: duration, animations: {
                self.textField.origin.y = self.view.height - keyboardSize.height - self.textField.height
            })
            
        }
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
    
    // Auto rewind player
    func playerDidFinishPlaying(_ notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero)
        }
    }
    
    func back(){
        player?.pause()
        self.dismiss(animated: true) {
            //
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit {
        player?.replaceCurrentItem(with: nil)
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}
