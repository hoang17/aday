//
//  HomeViewController.swift
//  Group
//
//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics
import DigitsKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import SnapKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setup like button
        let likeView : FBSDKLikeControl = FBSDKLikeControl()
        likeView.objectID = "https://google.com"
        self.view.addSubview(likeView)
        likeView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(50)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // Setup my profile button
        let button = UIButton(type: .System)
        button.setTitle("My Profile", forState: .Normal)
        button.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(viewMyProfile), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // Setup logout button
        let logoutButton = UIButton(type: .System)
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        logoutButton.backgroundColor = view.tintColor
        logoutButton.layer.cornerRadius = 3
        logoutButton.addTarget(self, action: #selector(logOut), forControlEvents: .TouchUpInside)
        self.view.addSubview(logoutButton)
        logoutButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(150)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
    }
    
    func viewMyProfile() {
        
        // Associate the session userID with user model
        let currentUser = (FIRAuth.auth()?.currentUser)!
        
        // Display message
        let message = "\(currentUser.displayName!) - \(currentUser.email!) \n \(Digits.sharedInstance().session()!.phoneNumber)"
        let alertController = UIAlertController(title: "You are logged in!", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: .None))
        self.presentViewController(alertController, animated: true, completion: .None)
    }
    
    func logOut() {
        do{
            FBSDKLoginManager().logOut()
            Digits.sharedInstance().logOut()
            try FIRAuth.auth()?.signOut()
            print("User Logged Out")
            
            // navigate to login
            let navViewController = self.parentViewController as! UINavigationController;
            navViewController.popViewControllerAnimated(true)
            
        } catch {
            print("Logout error")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

