//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics
import DigitsKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Image")!)
        let background = UIImage(named: "Image")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        
        // Setup login button
        let loginButton = FBSDKLoginButton()
        self.view.addSubview(loginButton)
        
        loginButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        loginButton.readPermissions = ["public_profile", "email", "user_friends", "user_likes", "user_location"]
        loginButton.delegate = self        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            // navigate to home
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.showMain()
            
            syncContacts()
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            // Process error
            print(error)
            print("login error")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("login cancel")
        }
        else {
            print("User Logged In")
            
            // Save Facebook login user
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (currentUser, error) in
                
                let ref = FIRDatabase.database().reference()
                
                let uid = currentUser!.uid
                
                // Associate the session userID with user model
                let user = ["uid": uid,
                            "name": currentUser!.displayName!,
                            "email": currentUser!.email!,
                            "fb": FBSDKAccessToken.currentAccessToken().userID,
                            "fb_token": FBSDKAccessToken.currentAccessToken().tokenString]
                ref.child("users").child(uid).updateChildValues(user)
                
                let update = ["/users/\(uid)/friends/\(uid)/": true]
                ref.updateChildValues(update)
            }
            
            showDigitsLogin()
        }
    }
    
    func showDigitsLogin() {
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.phoneNumber = "+84"
        Digits.sharedInstance().authenticateWithViewController(self, configuration: configuration) { (session, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            // Associate the session userID with user model
            let currentUser = (FIRAuth.auth()?.currentUser)!
            let user = ["fabric": (session?.userID)!,
                        "phone": (session?.phoneNumber)!]
            FIRDatabase.database().reference().child("users").child(currentUser.uid).updateChildValues(user)
            
            // navigate to home
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.showMain()
            
//            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        do {
            Digits.sharedInstance().logOut()
            try FIRAuth.auth()?.signOut()
            print("User Logged Out")
        } catch {
            print(error)
        }
    }
    
    func syncContacts() {
        let friendloader = FriendsLoader()
        friendloader.loadFacebookFriends()
        friendloader.loadAddressBook()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

