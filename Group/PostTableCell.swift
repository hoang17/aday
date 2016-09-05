/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */
import Foundation
import UIKit
import MGSwipeTableCell

class PostIndicatorView: UIView {
    
    var _indicatorColor: UIColor?
    var _innerColor: UIColor?
    
    override func drawRect(rect: CGRect) {
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextAddEllipseInRect(ctx, rect)
        CGContextSetFillColor(ctx, CGColorGetComponents(_indicatorColor!.CGColor))
        CGContextFillPath(ctx)
        if (_innerColor != nil) {
            let innerSize: CGFloat = rect.size.width * 0.5
            let innerRect: CGRect = CGRectMake(rect.origin.x + rect.size.width * 0.5 - innerSize * 0.5, rect.origin.y + rect.size.height * 0.5 - innerSize * 0.5, innerSize, innerSize)
            CGContextAddEllipseInRect(ctx, innerRect)
            CGContextSetFillColor(ctx, CGColorGetComponents(_innerColor!.CGColor))
            CGContextFillPath(ctx)
        }
    }
    
    func setIndicatorColor(indicatorColor: UIColor?) {
        self._indicatorColor = indicatorColor
        self.setNeedsDisplay()
    }
    
    func setInnerColor(innerColor: UIColor?) {
        self._innerColor = innerColor
        self.setNeedsDisplay()
    }
}

class PostTableCell : MGSwipeTableCell {
    var titleLabel: UILabel?
    var bodyLabel: UILabel?
    var timeLabel: UILabel?
    var indicatorView: PostIndicatorView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel = UILabel()
        self.bodyLabel = UILabel()
        self.timeLabel = UILabel()
        
        self.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 13.0)
        self.bodyLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        self.timeLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        
        self.bodyLabel!.textColor = UIColor.grayColor()
        
        self.indicatorView = PostIndicatorView(frame: CGRectMake(0, 0, 6, 6))
        self.indicatorView!.backgroundColor = UIColor.clearColor()

//        self.titleLabel!.backgroundColor = UIColor.greenColor()
//        self.bodyLabel!.backgroundColor = UIColor.yellowColor()
//        self.timeLabel!.backgroundColor = UIColor.grayColor()
        
        self.contentView.addSubview(titleLabel!)
        self.contentView.addSubview(bodyLabel!)
        
//        self.contentView.addSubview(timeLabel!)

        self.contentView.addSubview(indicatorView!)
        
        self.titleLabel?.numberOfLines = 2
        self.bodyLabel?.numberOfLines = 2
        
        self.titleLabel?.width = self.contentView.bounds.size.width
        self.bodyLabel?.width = self.contentView.bounds.size.width
        
        self.titleLabel?.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(5)
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-10)
        }
        
        self.bodyLabel?.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.contentView).offset(-5)
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftPadding: CGFloat = 15.0
        self.indicatorView!.center = CGPointMake(leftPadding * 0.5, 11)
    }

    
    func setTitle(title: String){
        let text = NSMutableAttributedString(string: title)
        text.yy_lineSpacing = 2
        text.yy_lineBreakMode = .ByTruncatingTail
        self.titleLabel?.attributedText = text
    }
    
    func setBody(body: String){
        let text = NSMutableAttributedString(string: body)
        text.yy_lineSpacing = 2
        text.yy_lineBreakMode = .ByTruncatingTail
        self.bodyLabel?.attributedText = text
    }
}