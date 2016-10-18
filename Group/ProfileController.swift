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
import SafariServices

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
                row.value = AppDelegate.currentUser.name
                row.disabled = true
            }
//            <<< AccountRow(){
//                $0.title = "Username"
//                $0.value = AppDelegate.currentUser?.username
//                $0.placeholder = "Enter your username"
//            }
//                .onChange({ row in
//                    let uid : String! = AppDelegate.uid
//                    let update = ["username": row.value ?? ""]
//                    let ref = FIRDatabase.database().reference().child("users").child(uid)
//                    ref.updateChildValues(update)
//                })
            <<< PhoneRow(){
                $0.title = "Mobile Number"
                $0.placeholder = "Enter your mobile number"
                $0.value = AppDelegate.currentUser?.phone
                $0.disabled = true
            }
            <<< EmailRow(){
                $0.title = "Email"
                $0.placeholder = "Enter your email address"
                $0.value = AppDelegate.currentUser.email
                $0.disabled = true
            }
//            <<< PasswordRow(){
//                $0.title = "Password"
//                $0.value = AppDelegate.currentUser?.password
//                $0.placeholder = "Enter your password"
//            }
//                .onChange({ row in
////                    let values = self.form.values()
////                    let email = values["email"] as! String
//                    let password = row.value ?? ""
//                    
//                    let uid : String! = AppDelegate.uid
//                    let update = ["password": password]
//                    let ref = FIRDatabase.database().reference().child("users").child(uid)
//                    ref.updateChildValues(update)
//                    
////                    let credential = FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
////                    FIRAuth.auth()?.currentUser!.linkWithCredential(credential) { (user, error) in
////                        if error == nil {
////                            print("linked \(user)")
////                        } else {
////                            print(error)
////                        }
////                    }
//
//                })
//            <<< DateRow(){
//                $0.title = "Birthday"
//                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
//            }
//            <<< ButtonRow("Notification"){
//                $0.title = $0.tag
//                $0.presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback{
//                    return CameraViewController()
//                }, completionCallback: nil)
//            }
            
            +++ Section("Support")
            <<< ButtonRow("Get Help from Twitter"){
                $0.title = $0.tag
            }
                .onCellSelection({ (cell, row) in
                    let url = "https://mobile.twitter.com/pinly_app"
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    }
                })
//            <<< ButtonRow("Report Issues"){
//                $0.title = $0.tag
//            }
//                .onCellSelection({ (cell, row) in
//                    let url = "https://m.facebook.com/pinlyapp/"
//                    if #available(iOS 9.0, *) {
//                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
//                        self.presentViewController(vc, animated: true, completion: nil)
//                    } else {
//                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
//                    }
//                })

            <<< ButtonRow("Send Suggestions"){
                $0.title = $0.tag
            }
                .onCellSelection({ (cell, row) in
                    let url = "https://m.facebook.com/pinlyapp/"
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    }
                })
            <<< ButtonRow("Business Contact"){
                $0.title = $0.tag
            }
                .onCellSelection({ (cell, row) in
                    let url = "https://m.facebook.com/pinlyapp/"
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    }
                })
        
            +++ Section("More Information")
            <<< ButtonRow("Privacy Policy"){
                $0.title = $0.tag
                }
                .onCellSelection({ (cell, row) in
                    let url = "https://hoang17.github.io/html/privacy"
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    }
                })
            
            <<< ButtonRow("Terms of Service"){
                $0.title = $0.tag
                }
                .onCellSelection({ (cell, row) in
                    let url = "https://hoang17.github.io/html/terms"
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: NSURL(string: url)!)
                        self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    }
                })
            
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
//            <<< ButtonRow("Clear Cache"){
//                $0.title = $0.tag
//                }
//                .cellUpdate({ (cell, row) in
//                    cell.accessoryType = .None
//                })
//                .onCellSelection({ (cell, row) in
//                    self.clearCache()
//                })
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
        // TODO
    }

    func syncContacts() {
        FriendsLoader.sharedInstance.loadFacebookFriends(nil)
        FriendsLoader.sharedInstance.loadAddressBook()
    }
    
//    func fixFriends(){
//        let ref = FIRDatabase.database().reference()
//        
//        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
//            
//            for item in snapshot.children {
//                
//                let user = User(snapshot: item as! FIRDataSnapshot)
//                for fuid in user.following.keys {
//                    
//                    let friend = Friend(uid: user.uid, fuid: fuid)
//                    ref.child("friends/\(user.uid)/\(fuid)").setValue(friend.toAnyObject())
//                }
//                
//                for fuid in user.friends.keys {
//                    
//                    let friend = Friend(uid: user.uid, fuid: fuid)
//                    ref.child("friends/\(user.uid)/\(fuid)").setValue(friend.toAnyObject())
//                }
//                
//            }
//        })
//    }
    
//    func fixClips() {
//        let ref = FIRDatabase.database().reference()
//
//        var i = 0
//
//        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
//
//            for item in snapshot.children {
//                
//                let user = User(snapshot: item as! FIRDataSnapshot)
//                for clip in user.clips {
//                    
//                    ref.child("pins/\(user.uid)/\(clip.id)").setValue(clip.toAnyObject())
//                    
//                    i+=1
//                    print(i)
//                    
////                    // RESTORE FUCKING THUMB
////                    
////                    let storage = FIRStorage.storage()
////                    let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/thumbs")
////                    let filename = clip.fname + ".jpg"
////                    
////                    gs.child(filename).metadataWithCompletion { (metadata, error) -> Void in
////                        if (error != nil) {
////                            print(error)
////                        } else {
////                            i+=1
////                            print("update thumb \(i)")
////                            let thumb = (metadata!.downloadURL()?.absoluteString)!
////                            let childUpdates = ["/clips/\(clip.id)/thumb": thumb,
////                                "/users/\(user.uid)/clips/\(clip.id)/thumb": thumb]
////                            ref.updateChildValues(childUpdates)
////                        }
////                    }
//                }
//            }
//        })
//    }
    
    func logOut() {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            do{
                try FIRAuth.auth()?.signOut()
                Digits.sharedInstance().logOut()
                FBSDKLoginManager().logOut()
                print("user logged out")
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showLogin()
                
                try AppDelegate.realm.write {
                    AppDelegate.realm.deleteAll()
                }
                
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

