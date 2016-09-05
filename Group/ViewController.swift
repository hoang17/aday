//
//  ViewController.swift
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

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            // Setup login button
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            
            loginView.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(self.view).offset(100)
                make.left.equalTo(self.view).offset(50)
                make.right.equalTo(self.view).offset(-50)
            }
            
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("User Logged In")
        
        //returnUserData()
        
        let fdbref = FIRDatabase.database().reference()
        
        // Save Facebook login user
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (currentUser, error) in
            print(currentUser!.displayName)
            
            let session = Digits.sharedInstance().session()
            if (session != nil){
                // Associate the session userID with user model
                let user = ["name": currentUser!.displayName!,
                            "email": currentUser!.email!,
                            "fabric": (session?.userID)!,
                            "phone": (session?.phoneNumber)!]
                fdbref.child("users").child(currentUser!.uid).setValue(user)
            }
            else{
                fdbref.child("users").child(currentUser!.uid).setValue(["name": currentUser!.displayName!,"email": currentUser!.email!])
            }
        }
        
        // Setup Fabric
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.phoneNumber = "+84"
        Digits.sharedInstance().authenticateWithViewController(self, configuration: configuration) { (session, error) in
            
            // Associate the session userID with user model
            let currentUser = (FIRAuth.auth()?.currentUser)!
            let user = ["name": currentUser.displayName!,
                "email": currentUser.email!,
                "fabric": (session?.userID)!,
                "phone": (session?.phoneNumber)!]
            fdbref.child("users").child(currentUser.uid).setValue(user)
            
            // navigate to home
            let navViewController = self.parentViewController as! UINavigationController;
            navViewController.pushViewController(HomeViewController(), animated: true)
        }
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // not implement use logout button on home
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                //let userName : NSString = result.valueForKey("name") as! NSString
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

