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
    var txtLabel = UILabel()
    //var txtLabel = YYLabel()
    //var followButton = UIButton()
    
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
        profileImg.backgroundColor = UIColor.brownColor()
        
        nameLabel.origin = CGPoint(x: 55, y: 2)
        nameLabel.size = CGSize(width: self.width, height: 24)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = comment.user?.name
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        txtLabel.origin = CGPoint(x: 55, y: 26)
        txtLabel.size = CGSize(width: self.width-60, height: 24)
        txtLabel.textColor = UIColor.blackColor()
        txtLabel.text = comment.txt
        txtLabel.font = UIFont.systemFontOfSize(12.0)
        txtLabel.numberOfLines = 0
        txtLabel.lineBreakMode = .ByWordWrapping
        txtLabel.sizeToFit()
        
        self.addSubview(nameLabel)
        self.addSubview(profileImg)
        self.addSubview(txtLabel)
        
//        followButton.size = CGSize(width: 80, height: 35)
//        followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//        self.addSubview(followButton)
//        followButton.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.top).offset(4)
//            make.right.equalTo(self.right).offset(-10)
//            
//        }
    }
}

