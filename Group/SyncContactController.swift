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
        
        let one = NSMutableAttributedString(string: "Shadow")
        one.yy_font = UIFont.boldSystemFontOfSize(30)
        one.yy_color = UIColor.whiteColor()
        let shadow = YYTextShadow()
        shadow.color = UIColor(white: 0.000, alpha: 0.490)
        shadow.offset = CGSizeMake(0, 1)
        shadow.radius = 5
        one.yy_textShadow = shadow
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(one)
        text.appendAttributedString(self.padding())

        let one1 = NSMutableAttributedString(string: "Border")
        one1.yy_font = UIFont.boldSystemFontOfSize(30)
        one1.yy_color = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
        let border = YYTextBorder()
        border.strokeColor = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
        border.strokeWidth = 3
        border.lineStyle = YYTextLineStyle.PatternCircleDot
        border.cornerRadius = 3
        border.insets = UIEdgeInsetsMake(0, -4, 0, -4)
        one1.yy_textBackgroundBorder = border
        text.appendAttributedString(self.padding())
        text.appendAttributedString(one1)
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        text.appendAttributedString(self.padding())
        
        let one2 = NSMutableAttributedString(string: "Sync Contacts")
        one2.yy_font = UIFont.boldSystemFontOfSize(30)
        one2.yy_underlineStyle = NSUnderlineStyle.StyleSingle
        one2.yy_setTextHighlightRange(one2.yy_rangeOfAll(),
                                     color: UIColor(red: 0.093, green: 0.492, blue: 1.000, alpha: 1.000),
                                     backgroundColor: UIColor(white: 0.000, alpha: 0.220),
                                     tapAction: { (containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
                                        
                                        self.showMessage("Tap: message")
        })
        text.appendAttributedString(one2)
        text.appendAttributedString(self.padding())
        
//        text.yy_alignment = .Center        
//        let container = YYTextContainer(size: CGSizeMake(self.view.width, self.view.height -  64))
//        container.insets = UIEdgeInsetsMake(10, 10, 10, 10)
//        let layout = YYTextLayout(container: container, text: text)
        
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
        
        // label.textLayout = layout;
        
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
