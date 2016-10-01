//
//  ClipCalloutView.swift
//  Group
//
//  Created by Hoang Le on 9/28/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Kingfisher
import FirebaseStorage

class ClipCalloutView: UIView {
    
    var miniPlayer: MiniPlayer!
    let textField = UITextField()
    var dateLabel = UILabel()
    var profileImg = UIImageView()
    
    init(clip: Clip, frame: CGRect) {
        super.init(frame: frame)
        
        let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: clip.uid)
        
        miniPlayer = MiniPlayer(clip: clip, frame: frame)
        miniPlayer.layer.cornerRadius = 5
        miniPlayer.layer.masksToBounds = false
        miniPlayer.clipsToBounds = true
        
        profileImg.origin = CGPoint(x: frame.width/2-12, y: frame.height+34)
        profileImg.size = CGSize(width: 19, height: 19)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.layer.borderWidth = 0.5
        profileImg.layer.borderColor = UIColor.lightGrayColor().CGColor
        profileImg.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(user!.fb)/picture?type=large&return_ssl_resources=1"))
        
        if clip.txt == "" {
            textField.hidden = true
        }
        else {
            textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            textField.textColor = UIColor.whiteColor()
            textField.font = UIFont.systemFontOfSize(10)
            textField.textAlignment = NSTextAlignment.Center
            textField.height = 20
            textField.width = frame.width
            textField.userInteractionEnabled = false
            textField.text = clip.txt
            textField.center.y =  frame.height * clip.y
        }
        dateLabel.origin = CGPoint(x: 5, y: 3)
        dateLabel.text = NSDate(timeIntervalSince1970: clip.date).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: 10)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.8)
        dateLabel.font = UIFont(name: "OpenSans", size: 9.0)
        
        addSubview(miniPlayer)
        addSubview(profileImg)
        addSubview(textField)
        addSubview(dateLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
