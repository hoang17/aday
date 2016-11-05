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
        
        self.selectionStyle = .none
        
        profileImg.origin = CGPoint(x: 8, y: 10)
        profileImg.size = CGSize(width: 35, height: 35)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        profileImg.contentMode = .scaleAspectFit
        let fb: String = comment.user?.fb ?? ""
        let imgUrl = URL(string: "https://graph.facebook.com/\(fb)/picture?type=large&return_ssl_resources=1")
        profileImg.kf.setImage(with: imgUrl)
        
        nameLabel.origin = CGPoint(x: 55, y: 2)
        nameLabel.size = CGSize(width: width, height: 24)
        nameLabel.textColor = UIColor.black
        nameLabel.text = comment.user?.name
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        
        dateLabel.origin = CGPoint(x: width-40, y: 2)
        dateLabel.size = CGSize(width: 32, height: 24)
        dateLabel.textColor = UIColor(white: 0.3, alpha: 0.5)
        dateLabel.font = UIFont(name: "OpenSans-Bold", size: 10.0)
        dateLabel.text = (Date(timeIntervalSince1970: comment.created) as NSDate).shortTimeAgoSinceNow()
        dateLabel.textAlignment = .right
        
        txtLabel.origin = CGPoint(x: 55, y: 26)
        txtLabel.size = CGSize(width: self.width-60, height: 24)
        txtLabel.textColor = UIColor.black
        txtLabel.text = comment.txt
        txtLabel.font = UIFont.systemFont(ofSize: 12.0)
        txtLabel.numberOfLines = 0
        txtLabel.lineBreakMode = .byWordWrapping
        txtLabel.sizeToFit()
        
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        self.addSubview(profileImg)
        self.addSubview(txtLabel)
    }
}

