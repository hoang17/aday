//
//  SyncContactController.swift
//  Pinly
//
//  Created by Hoang Le on 10/18/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import APAddressBook
import DigitsKit
import RealmSwift
import YYText
import CWStatusBarNotification

class SyncContactController: UIViewController {
    
    var count: Int = 0
    
    convenience init(count: Int){
        self.init()
        self.count = count
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Find Friends"
        
        let name = FIRAuth.auth()?.currentUser?.displayName ?? ""
        
        let hey = NSMutableAttributedString(string: "Hey \(name)!")
        hey.yy_font = UIFont.boldSystemFontOfSize(30)
        hey.yy_color = UIColor(red: 1.0, green: 0.029, blue: 0.651, alpha: 1.0)
        hey.yy_setColor(UIColor(red: 0.093, green: 0.492, blue: 1.0, alpha: 1.0), range: NSMakeRange(4, name.characters.count))
        hey.yy_lineSpacing = 10
        
        let s = count > 1 ? "Let's find your friends using Pinly" : "Seem like you dont have any friends yet! Let's add some friends to start using Pinly"
        let text = NSMutableAttributedString(string: s)
        text.yy_font = UIFont.boldSystemFontOfSize(24)
        text.yy_color = UIColor(red: 0.093, green: 0.492, blue: 1.0, alpha: 1.0)
        text.yy_lineSpacing = 10
        
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(text)
        
        // text.yy_setColor(UIColor(red: 1.0, green: 0.029, blue: 0.651, alpha: 1.0), range: NSMakeRange(0, 4))
        
        let one = NSMutableAttributedString(string: "Sync Contacts")
        
        one.yy_font = UIFont.boldSystemFontOfSize(30)
        one.yy_color = UIColor(red: 1.0, green: 0.029, blue: 0.651, alpha: 1.0)
        
        let border = YYTextBorder()
        border.cornerRadius = 10
        border.insets = UIEdgeInsetsMake(-10, -10, -10, -10)
        border.strokeWidth = 3
        border.strokeColor = one.yy_color
        border.lineStyle = .PatternCircleDot
        
        let highlightBorder = border.copy() as! YYTextBorder
        highlightBorder.strokeWidth = 0
        highlightBorder.strokeColor = one.yy_color
        highlightBorder.fillColor = one.yy_color
        
        let highlight = YYTextHighlight()
        highlight.setColor(UIColor.whiteColor())
        highlight.setBackgroundBorder(highlightBorder)
        highlight.tapAction = {(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void in
            self.syncContacts()
        }
        
        one.yy_textBackgroundBorder = border
        one.yy_setTextHighlight(highlight, range: one.yy_rangeOfAll())
        
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(self.padding())
        hey.appendAttributedString(one)
        
        
        let label = YYLabel()
        label.attributedText = hey
        label.width = self.view.width
        label.height = self.view.height -  64
        label.top = 64
        label.textAlignment = .Center
        label.textVerticalAlignment = .Center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.933, alpha: 0.5)
        label.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = view.bounds
        view.insertSubview(visualEffectView, atIndex: 0)
        
        self.view.addSubview(label)
        
        if count > 1 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
        }
    }
    
    func dismiss(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func syncContacts() {
        
        let notification = CWStatusBarNotification()
        notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
        notification.displayNotificationWithMessage("Finding friends...", forDuration: 3.0)
        
        FriendsLoader.sharedInstance.loadFacebookFriends { count in
            let notification = CWStatusBarNotification()
            notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
            notification.displayNotificationWithMessage("Syncing friends...", forDuration: 3.0)
        }
        
        FriendsLoader.sharedInstance.loadAddressBook {
            let notification = CWStatusBarNotification()
            notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
            notification.displayNotificationWithMessage("Syncing contacts...", forDuration: 10.0)
            
            self.navigationController?.pushViewController(SuggestFriendController(), animated: true)
            // self.presentViewController(SearchController(), animated: true, completion: nil)
        }
    }
    
    func padding() -> NSAttributedString {
        let pad = NSMutableAttributedString(string: "\n\n")
        pad.yy_font = UIFont.systemFontOfSize(4)
        return pad
    }
}
