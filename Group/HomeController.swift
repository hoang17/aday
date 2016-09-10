//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics
import DigitsKit
import FBSDKLoginKit
import SnapKit

class HomeController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // Logout button
        let logoutButton = UIButton(type: .System)
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        logoutButton.backgroundColor = view.tintColor
        logoutButton.layer.cornerRadius = 3
        logoutButton.addTarget(self, action: #selector(logOut), forControlEvents: .TouchUpInside)
        self.view.addSubview(logoutButton)
        logoutButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(20)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // My profile button
        let button = UIButton(type: .System)
        button.setTitle("My Profile", forState: .Normal)
        button.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(openMyProfile), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(70)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // Sync contacts button
        let button1 = UIButton(type: .System)
        button1.setTitle("Sync Contacts", forState: .Normal)
        button1.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button1.backgroundColor = view.tintColor
        button1.layer.cornerRadius = 3
        button1.addTarget(self, action: #selector(syncContacts), forControlEvents: .TouchUpInside)
        self.view.addSubview(button1)
        button1.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(120)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }

        // Sync facebook friends
        let button3 = UIButton(type: .System)
        button3.setTitle("Sync Friends", forState: .Normal)
        button3.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button3.backgroundColor = view.tintColor
        button3.layer.cornerRadius = 3
        button3.addTarget(self, action: #selector(syncFacebookFriends), forControlEvents: .TouchUpInside)
        self.view.addSubview(button3)
        button3.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(220)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // Clips
        let button2 = UIButton(type: .System)
        button2.setTitle("Clips", forState: .Normal)
        button2.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button2.backgroundColor = view.tintColor
        button2.layer.cornerRadius = 3
        button2.addTarget(self, action: #selector(openMyFriends), forControlEvents: .TouchUpInside)
        self.view.addSubview(button2)
        button2.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(170)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
        // New clip
        let button4 = UIButton(type: .System)
        button4.setTitle("New Clip", forState: .Normal)
        button4.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button4.backgroundColor = view.tintColor
        button4.layer.cornerRadius = 3
        button4.addTarget(self, action: #selector(addVideo), forControlEvents: .TouchUpInside)
        self.view.addSubview(button4)
        button4.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(270)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
    }

    func addVideo() {
        let cameraView = CameraViewController()
        self.presentViewController(cameraView, animated: true, completion: nil)
    }

    func syncFacebookFriends(){
        let friendloader = LoadFriends()
        friendloader.loadFacebookFriends { (friends) in
            // TODO
        }
    }

    func openMyFriends() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(FriendsController(), animated: true)
    }
    
    func syncContacts() {
        // TODO
    }
    
    func openMyProfile() {
        let currentUser = (FIRAuth.auth()?.currentUser)!
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
            self.navigationController!.popViewControllerAnimated(true)
            
        } catch {
            print(error)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

