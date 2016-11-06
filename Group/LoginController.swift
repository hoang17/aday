//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import DigitsKit
import FBSDKCoreKit
import FBSDKLoginKit
import ActiveLabel
import SafariServices

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIImage(named: "Image")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        
        // Setup login button
        self.view.addSubview(loginButton)
        
        loginButton.snp.makeConstraints { [weak self] (make) in
            make.center.equalTo(self!.view)
            make.left.equalTo(self!.view).offset(50)
            make.right.equalTo(self!.view).offset(-50)
        }
        loginButton.readPermissions = ["public_profile", "email", "user_friends", "user_likes", "user_location"]
        loginButton.delegate = self
        
        
        // Setting label
        
        let label = ActiveLabel()
        
        let term = ActiveType.custom(pattern: "\\sTerms of Service\\b")
        let privacy = ActiveType.custom(pattern: "\\sPrivacy Policy\\b")
        
        label.enabledTypes = [term, privacy]
        label.customColor[term] = UIColor.purple
        label.customSelectedColor[term] = UIColor.blue
        label.customColor[privacy] = UIColor.purple
        label.customSelectedColor[privacy] = UIColor.blue
        
        label.text = "By tapping Login with Facebook, you agree\n to the Terms of Service and Privacy Policy"
        label.numberOfLines = 0
        label.lineSpacing = 4
        label.textColor = .black
        label.font = UIFont(name: "OpenSans", size: 13.0)
        
        label.handleCustomTap(for: term) { element in
            let url = "https://hoang17.github.io/html/terms"
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(url: URL(string: url)!)
                self.present(vc, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
        
        label.handleCustomTap(for: privacy) { element in
            let url = "https://hoang17.github.io/html/privacy"
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(url: URL(string: url)!)
                self.present(vc, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
        
        self.view.addSubview(label)
        
        label.snp.makeConstraints { [weak self] (make) in
            make.centerX.equalTo(self!.view)
            make.bottom.equalTo(self!.view).offset(-150)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            // navigate to home
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showMain()
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
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
            print("User logged In")
            
            loginButton.isHidden = true
            
            let text = "Logging in..."
            self.showWaitOverlayWithText(text)
            
            // Save Facebook login user
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { [weak self] (currentUser, error) in
                
                let uid = currentUser!.uid
                
                let ref = FIRDatabase.database().reference()
                
                print("loading user")
                
                ref.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                    
                    print("loaded snapshot")
                    
                    if snapshot.value is NSNull {
                        
                        let name = currentUser!.displayName!
                        let fb = FBSDKAccessToken.current().userID
                        let fbtoken = FBSDKAccessToken.current().tokenString
                        let email = currentUser!.email ?? ""
                        
                        let u = User(uid: uid, name: name, email: email, fb: fb!, fbtoken: fbtoken!)
                        AppDelegate.currentUser = UserModel(user: u)
                        try! AppDelegate.realm.write {
                            AppDelegate.realm.add(AppDelegate.currentUser, update: true)
                        }
                        
                        self?.showDigitsLogin()
                        
                        let user = ["uid": uid,
                            "name": name,
                            "email": email,
                            "fb": fb!,
                            "fbtoken": fbtoken!,
                            "created": Date().timeIntervalSince1970] as AnyObject
                        
                        let friend = Friend(uid: uid, fuid: uid)
                        
                        var update = [String: Any]()
                        update["/users/\(uid)"] = user
                        update["/friends/\(uid)/\(uid)"] = friend.toAnyObject()
                        
                        ref.updateChildValues(update)
                        return
                    }
                    
                    let user = User(snapshot: snapshot)
                    AppDelegate.currentUser = UserModel(user: user)
                    try! AppDelegate.realm.write {
                        AppDelegate.realm.add(AppDelegate.currentUser, update: true)
                    }
                    
                    if (AppDelegate.currentUser.phone == "") {
                        self?.showDigitsLogin()
                    } else {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.showMain()
                    }
                })
                
            }
            
        }
    }
    
    func showDigitsLogin() {
        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        configuration?.phoneNumber = "+84"
        Digits.sharedInstance().authenticate(with: self, configuration: configuration!) { (session, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            // Associate the session userID with user model
            let currentUser = (FIRAuth.auth()?.currentUser)!
            let user = ["fabric": (session?.userID)!,
                        "phone": (session?.phoneNumber)!]
            FIRDatabase.database().reference().child("users").child(currentUser.uid).updateChildValues(user)
            
            // navigate to home
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showMain()
            
//            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        do {
            Digits.sharedInstance().logOut()
            try FIRAuth.auth()?.signOut()
            print("User Logged Out")
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

