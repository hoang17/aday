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
import SnapKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController!.setNavigationBarHidden(true, animated: false)
        
        // Setup login button
        let loginButton = FBSDKLoginButton()
        self.view.addSubview(loginButton)
        
        loginButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        loginButton.readPermissions = ["public_profile", "email", "user_friends", "user_likes"]
        loginButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil && Digits.sharedInstance().session() == nil){
            showDigitsLogin()
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error != nil) {
            // Process error
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
                let session = Digits.sharedInstance().session()
                if (session != nil){
                    // Associate the session userID with user model
                    let user = ["name": currentUser!.displayName!,
                                "email": currentUser!.email!,
                                "fb": FBSDKAccessToken.currentAccessToken().userID,
                                "fabric": (session?.userID)!,
                                "phone": (session?.phoneNumber)!]
                    FIRDatabase.database().reference().child("users").child(currentUser!.uid).setValue(user)
                }
                else{
                    FIRDatabase.database().reference().child("users").child(currentUser!.uid).setValue(["name": currentUser!.displayName!,"email": currentUser!.email!])
                }
            }
            
            showDigitsLogin()
        }
    }
    
    func showDigitsLogin() {
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.phoneNumber = "+84"
        Digits.sharedInstance().authenticateWithViewController(self, configuration: configuration) { (session, error) in
            
            if ((error) != nil) {
                return
            }
            
            // Associate the session userID with user model
            let currentUser = (FIRAuth.auth()?.currentUser)!
            let user = ["name": currentUser.displayName!,
                        "email": currentUser.email!,
                        "fb": FBSDKAccessToken.currentAccessToken().userID,
                        "fabric": (session?.userID)!,
                        "phone": (session?.phoneNumber)!]
            FIRDatabase.database().reference().child("users").child(currentUser.uid).setValue(user)
            
            // navigate to home            
            self.dismissViewControllerAnimated(true, completion: nil)
//            self.navigationController!.pushViewController(HomeController(), animated: false)
//            self.navigationController!.pushViewController(FriendsController(), animated: true)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do{
            Digits.sharedInstance().logOut()
            try FIRAuth.auth()?.signOut()
            print("User Logged Out")
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

