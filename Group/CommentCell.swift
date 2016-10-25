//
//  CommentCell.swift
//  Pinly
//
//  Created by Hoang Le on 10/24/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit
import YYText

class CommentCell: UITableViewCell{
    
    var nameLabel = UILabel()
    var profileImg = UIImageView()
    var dateLabel = UILabel()
    var txtLabel = UILabel()
    
    convenience init(comment: Comment) {
        self.init()
        
        self.selectionStyle = .None
        
        profileImg.origin = CGPoint(x: 8, y: 10)
        profileImg.size = CGSize(width: 35, height: 35)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.contentMode = .ScaleAspectFit
        let fb: String = comment.user?.fb ?? ""
        let imgUrl = NSURL(string: "https://graph.facebook.com/\(fb)/picture?type=large&return_ssl_resources=1")
        profileImg.kf_setImageWithURL(imgUrl)
        
        nameLabel.origin = CGPoint(x: 55, y: 2)
        nameLabel.size = CGSize(width: width, height: 24)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = comment.user?.name
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        dateLabel.origin = CGPoint(x: width-40, y: 2)
        dateLabel.size = CGSize(width: 32, height: 24)
        dateLabel.textColor = UIColor(white: 0.3, alpha: 0.5)
        dateLabel.font = UIFont(name: "OpenSans-Bold", size: 10.0)
        dateLabel.text = NSDate(timeIntervalSince1970: comment.created).shortTimeAgoSinceNow()
        dateLabel.textAlignment = .Right
        
        txtLabel.origin = CGPoint(x: 55, y: 26)
        txtLabel.size = CGSize(width: self.width-60, height: 24)
        txtLabel.textColor = UIColor.blackColor()
        txtLabel.text = comment.txt
        txtLabel.font = UIFont.systemFontOfSize(12.0)
        txtLabel.numberOfLines = 0
        txtLabel.lineBreakMode = .ByWordWrapping
        txtLabel.sizeToFit()
        
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        self.addSubview(profileImg)
        self.addSubview(txtLabel)
    }
}

