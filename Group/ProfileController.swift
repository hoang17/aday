//  Created by Hoang Le on 6/16/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics
import DigitsKit
import FBSDKLoginKit
import AVFoundation
import Eureka
import FirebaseStorage

class ProfileController: FormViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        form +++ Section() { section in
            section.header = {
                let header = HeaderFooterView<UIView>(.Callback({
                
                    let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
                    img.layer.cornerRadius = img.frame.height/2
                    img.layer.masksToBounds = false
                    img.clipsToBounds = true
                    img.contentMode = UIViewContentMode.ScaleAspectFit
                    if FBSDKAccessToken.currentAccessToken() != nil {
                        img.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/picture?type=large&return_ssl_resources=1"))
                    }
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 100))
                    img.center = view.center
                    img.y += 20
                    view.addSubview(img)
                    return view
                }))
                return header
            }()
        }
            
        form +++ Section("My Account")
            <<< NameRow(){ row in
                row.title = "Name"
                row.placeholder = "Enter your name"
                row.value = FIRAuth.auth()!.currentUser?.displayName
                row.disabled = true
            }
            <<< AccountRow(){
                $0.title = "Username"
                $0.value = AppDelegate.currentUser?.username
                $0.placeholder = "Enter your username"
            }
                .onChange({ row in
                    let uid : String! = FIRAuth.auth()?.currentUser?.uid
                    let update = ["username": row.value ?? ""]
                    let ref = FIRDatabase.database().reference().child("users").child(uid)
                    ref.updateChildValues(update)
                })
            <<< PhoneRow(){
                $0.title = "Mobile Number"
                $0.placeholder = "Enter your mobile number"
                $0.value = AppDelegate.currentUser?.phone
                $0.disabled = true
            }
            <<< EmailRow(){
                $0.title = "Email"
                $0.placeholder = "Enter your email address"
                $0.value = FIRAuth.auth()!.currentUser?.email
                $0.disabled = true
            }
            <<< PasswordRow(){
                $0.title = "Password"
                $0.value = AppDelegate.currentUser?.password
                $0.placeholder = "Enter your password"
            }
                .onChange({ row in
//                    let values = self.form.values()
//                    let email = values["email"] as! String
                    let password = row.value ?? ""
                    
                    let uid : String! = FIRAuth.auth()?.currentUser?.uid
                    let update = ["password": password]
                    let ref = FIRDatabase.database().reference().child("users").child(uid)
                    ref.updateChildValues(update)
                    
//                    let credential = FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
//                    FIRAuth.auth()?.currentUser!.linkWithCredential(credential) { (user, error) in
//                        if error == nil {
//                            print("linked \(user)")
//                        } else {
//                            print(error)
//                        }
//                    }

                })
//            <<< DateRow(){
//                $0.title = "Birthday"
//                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
//            }
            <<< ButtonRow("Notification"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                }, completionCallback: nil)
            }
            
            +++ Section("Support")
            <<< ButtonRow("Help Center"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
                
            }
            <<< ButtonRow("Report Issues"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
            }
            <<< ButtonRow("Send Suggestions"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
            }
            <<< ButtonRow("Business Contact"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
            }
        
            +++ Section("More Information")
            <<< ButtonRow("Privacy Policy"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
            }
            <<< ButtonRow("Terms of Service"){
                $0.title = $0.tag
                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
                    return CameraViewController()
                    }, completionCallback: nil)
            }
            
            +++ Section("Account Actions")
            <<< ButtonRow("Sync Contacts"){
                $0.title = $0.tag
                }
                .cellUpdate({ (cell, row) in
                    cell.accessoryType = .None
                })
                .onCellSelection({ (cell, row) in
                    self.syncContacts()
                })
            <<< ButtonRow("Clear Cache"){
                $0.title = $0.tag
                }
                .cellUpdate({ (cell, row) in
                    cell.accessoryType = .None
                })
                .onCellSelection({ (cell, row) in
                    self.clearCache()
                })
            <<< ButtonRow("Log Out"){
                $0.title = $0.tag
                }
                .cellUpdate({ (cell, row) in
                    cell.accessoryType = .None
                })
                .onCellSelection({ (cell, row) in
                    self.logOut()
                })
        
    }
    
    func clearCache(){
        
    }

    func syncFacebookFriends(){
        
        let friendloader = FriendsLoader()
        friendloader.loadFacebookFriends { (friends) in
            // TODO
        }
    }

    func syncContacts() {
        
        // TODO
        syncFacebookFriends()
        
    }
    
    func fixClips() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            for item in snapshot.children {
                
                let user = User(snapshot: item as! FIRDataSnapshot)
                for clip in user.clips {
                    ref.child("clips").child(clip.id).setValue(clip.toAnyObject())
                }
            }
        })
    }
    
    func logOut() {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            do{
                FBSDKLoginManager().logOut()
                Digits.sharedInstance().logOut()
                try FIRAuth.auth()?.signOut()
                print("user logged out")
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showLogin()
                
            } catch {
                print(error)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("logout cancelled")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

