//
//  SearchItemCell.swift
//  Pinly
//
//  Created by Hai Ng on 9/28/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

class SearchItemCell: UITableViewCell{
    
    var nameLabel = UILabel()
    var followButton = UIButton()
    var profileImg = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None;
        
        // Set cell profile img
        profileImg.origin = CGPoint(x: 10, y: 4)
        profileImg.size = CGSize(width: 35, height: 35)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
        self.addSubview(profileImg)
        
        // Set cell name label
        nameLabel.origin = CGPoint(x: 60, y: 4)
        nameLabel.size = CGSize(width: self.width, height: 35)
        nameLabel.textColor = UIColor.blackColor()
        self.addSubview(nameLabel)
        
        // Set cell follow button
        followButton.size = CGSize(width: 80, height: 35)
        followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.addSubview(followButton)
        followButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.top).offset(4)
            make.right.equalTo(self.right).offset(-10)
            
        }
    }
}
