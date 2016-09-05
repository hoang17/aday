/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */
import Foundation
import UIKit
import MGSwipeTableCell

class FeedTableCell : MGSwipeTableCell {
    var titleLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.width = self.contentView.bounds.size.width
        
        self.contentView.addSubview(titleLabel!)
        
        self.titleLabel?.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(4)
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String){
        let text = NSMutableAttributedString(string: title)
        text.yy_lineSpacing = 4
        text.yy_lineBreakMode = .ByTruncatingTail
        self.titleLabel?.attributedText = text
    }
}