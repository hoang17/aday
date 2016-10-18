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

class SyncContactController: UIViewController {
    
    override func viewDidLoad() {
        
        let text = NSMutableAttributedString(string: "Seem like you dont have any friends yet! You need to add some friends to start using Pinly")
        text.yy_font = UIFont.boldSystemFontOfSize(24)
        text.yy_color = UIColor.blueColor()
        text.yy_setColor(UIColor.redColor(), range: NSMakeRange(0, 4))
        text.yy_lineSpacing = 10
        
//        let shadow = YYTextShadow()
//        shadow.color = UIColor(white: 0.000, alpha: 0.490)
//        shadow.offset = CGSizeMake(0, 1)
//        shadow.radius = 5
//        one.yy_textShadow = shadow
        
//        let border = YYTextBorder()
//        border.strokeColor = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
//        border.strokeWidth = 3
//        border.lineStyle = .PatternCircleDot
//        border.cornerRadius = 3
//        border.insets = UIEdgeInsetsMake(0, -4, 0, -4)
        
        let one = NSMutableAttributedString(string: "Sync Contacts")
        
        one.yy_font = UIFont.boldSystemFontOfSize(30)
        one.yy_color = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
        // one.yy_color = UIColor(red: 0.093, green: 0.492, blue: 1.000, alpha: 1.000)
        
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
            self.showMessage("Tap: message")
        }
        
        one.yy_textBackgroundBorder = border
        one.yy_setTextHighlight(highlight, range: one.yy_rangeOfAll())
        
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(one)
        
        
        let label = YYLabel()
        label.attributedText = text
        label.width = self.view.width
        label.height = self.view.height -  64
        label.top = 64
        label.textAlignment = .Center
        label.textVerticalAlignment = .Center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.933, alpha: 1.000)
        label.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        self.view.addSubview(label)
    }
    
    func showMessage(msg: String) {
        let padding: CGFloat = 10
        let label = YYLabel()
        label.text = msg
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor(red: 0.033, green: 0.685, blue: 0.978, alpha: 0.730)
        label.width = self.view.width
        label.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding)
        // label.height = msg.heightForFont(label.font, width: label.width) + 2 * padding
        label.height = 30
        label.bottom = 64
        self.view.addSubview(label)
        UIView.animateWithDuration(0.3, animations: {() -> Void in
            label.top = 64
            }, completion: {(finished: Bool) -> Void in
                UIView.animateWithDuration(0.2, delay: 2, options: .CurveEaseInOut, animations: {() -> Void in
                    label.bottom = 64
                    }, completion: {(finished: Bool) -> Void in
                        label.removeFromSuperview()
                })
        })
    }
    
    func padding() -> NSAttributedString {
        let pad = NSMutableAttributedString(string: "\n\n")
        pad.yy_font = UIFont.systemFontOfSize(4)
        return pad
    }
}
