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
        
        // Setup logout button
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
        
        // Setup my profile button
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
        
        // Setup my contacts button
        let button1 = UIButton(type: .System)
        button1.setTitle("My Contacts", forState: .Normal)
        button1.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button1.backgroundColor = view.tintColor
        button1.layer.cornerRadius = 3
        button1.addTarget(self, action: #selector(openMyContacts), forControlEvents: .TouchUpInside)
        self.view.addSubview(button1)
        button1.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(120)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }

        // Setup my friends button
        let button2 = UIButton(type: .System)
        button2.setTitle("My Friends", forState: .Normal)
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
        
        // Setup my friends button
        let button3 = UIButton(type: .System)
        button3.setTitle("My Pages", forState: .Normal)
        button3.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button3.backgroundColor = view.tintColor
        button3.layer.cornerRadius = 3
        button3.addTarget(self, action: #selector(openMyPages), forControlEvents: .TouchUpInside)
        self.view.addSubview(button3)
        button3.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(220)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }

        
        // Setup Spotify button
//        let button4 = UIButton(type: .System)
//        button4.setTitle("Spotify", forState: .Normal)
//        button4.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
//        button4.backgroundColor = view.tintColor
//        button4.layer.cornerRadius = 3
//        button4.addTarget(self, action: #selector(openSpotifyDemo), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button4)
//        button4.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.view).offset(270)
//            make.left.equalTo(self.view).offset(50)
//            make.right.equalTo(self.view).offset(-50)
//        }

        // Setup MailApp button
//        let button5 = UIButton(type: .System)
//        button5.setTitle("Mail", forState: .Normal)
//        button5.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
//        button5.backgroundColor = view.tintColor
//        button5.layer.cornerRadius = 3
//        button5.addTarget(self, action: #selector(openMailAppDemo), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button5)
//        button5.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.view).offset(320)
//            make.left.equalTo(self.view).offset(50)
//            make.right.equalTo(self.view).offset(-50)
//        }

//        let button3 = UIButton(type: .System)
//        button3.setTitle("Load Friends", forState: .Normal)
//        button3.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
//        button3.backgroundColor = view.tintColor
//        button3.layer.cornerRadius = 3
//        button3.addTarget(self, action: #selector(loadFriends), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button3)
//        button3.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.view).offset(220)
//            make.left.equalTo(self.view).offset(50)
//            make.right.equalTo(self.view).offset(-50)
//        }

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
//    func loadFriends(){
//        let l = LoadFriends()
//        l.loadFriends()
//    }

    func openMailAppDemo() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(MailViewController(), animated: true)
    }

    func openSpotifyDemo() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(SpotifyViewController(), animated: true)
    }

    func openMyPages() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(PagesController(), animated: true)
    }
    
    func openMyFriends() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(FriendsController(), animated: true)
    }
    
    func openMyContacts() {
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(ContactsController(), animated: true)
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

