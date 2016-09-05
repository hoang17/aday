//
//  DynamicHeightCell.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 11/7/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import YYText

final class DynamicHeightCell: UITableViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set {
            var v = newValue
            if (v == nil){
                v = ""
                titleLabel.hidden = true
            }
            let richtext = NSMutableAttributedString(string: v!)
            richtext.yy_lineSpacing = 4
            titleLabel.attributedText = richtext
        }
    }
    
    var body: String? {
        get { return bodyLabel.text }
        set {
            var v = newValue
            if (v == nil){
                v = ""
            }
            let richtext = NSMutableAttributedString(string: v!)
            richtext.yy_font = UIFont.systemFontOfSize(13)
            richtext.yy_lineSpacing = 4
            richtext.yy_paragraphSpacing = 4
            bodyLabel.attributedText = richtext
        }
    }
    var bodyColor: UIColor? {
        get { return bodyLabel.textColor }
        set { bodyLabel.textColor = newValue }
    }
    
    /** Dynamic height row for iOS 7
     override func layoutSubviews() {
         super.layoutSubviews()
         titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
         bodyLabel.preferredMaxLayoutWidth = bodyLabel.bounds.width
     }
     **/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        titleLabel.font = UIFont(name: "HelveticaNeue", size:17.0)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
}