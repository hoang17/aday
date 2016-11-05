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
    
    convenience init(clip: ClipModel, frame: CGRect) {
        self.init(frame: frame)
        
        let user = AppDelegate.realm.object(ofType: UserModel.self, forPrimaryKey: clip.uid)
        
        miniPlayer = MiniPlayer(clip: clip, frame: frame)
        miniPlayer.layer.cornerRadius = 5
        miniPlayer.layer.masksToBounds = false
        miniPlayer.clipsToBounds = true
        
        profileImg.origin = CGPoint(x: frame.width/2-12, y: frame.height+35)
        profileImg.size = CGSize(width: 19, height: 19)
        profileImg.layer.cornerRadius = profileImg.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.layer.borderWidth = 0.5
        profileImg.layer.borderColor = UIColor.lightGray.cgColor
        profileImg.contentMode = .scaleAspectFit        
        profileImg.kf.setImage(with: URL(string: "https://graph.facebook.com/\(user!.fb)/picture?type=large&return_ssl_resources=1"))
        
        if clip.txt == "" {
            textField.isHidden = true
        }
        else {
            textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            textField.textColor = UIColor.white
            textField.font = UIFont.systemFont(ofSize: 10)
            textField.textAlignment = NSTextAlignment.center
            textField.height = 20
            textField.width = frame.width
            textField.isUserInteractionEnabled = false
            textField.text = clip.txt
            textField.center.y =  frame.height * CGFloat(clip.y)
        }
        dateLabel.origin = CGPoint(x: 5, y: 3)
        dateLabel.text = (Date(timeIntervalSince1970: clip.date) as NSDate).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: 10)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.8)
        dateLabel.font = UIFont(name: "OpenSans", size: 9.0)
        
        addSubview(miniPlayer)
        addSubview(profileImg)
        addSubview(textField)
        addSubview(dateLabel)
    }
    
    deinit {
        miniPlayer = nil
    }
}
