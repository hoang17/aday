/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */
import Foundation
import UIKit
import MGSwipeTableCell

class MailIndicatorView: UIView {
    
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

class MailTableCell : MGSwipeTableCell {
    var mailFrom: UILabel?
    var mailSubject: UILabel?
    var mailMessage: UITextView?
    var mailTime: UILabel?
    var indicatorView: MailIndicatorView?
    
    convenience init() {
        self.init(style: .Default, reuseIdentifier: "MailTableCell")
        self.mailFrom = UILabel(frame: CGRectZero)
        self.mailMessage = UITextView(frame: CGRectZero)
        self.mailSubject = UILabel(frame: CGRectZero)
        self.mailTime = UILabel(frame: CGRectZero)
        self.mailFrom!.font = UIFont(name: "HelveticaNeue", size: 18.0)
        self.mailSubject!.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        self.mailMessage!.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        self.mailTime!.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        self.mailMessage!.scrollEnabled = false
        self.mailMessage!.editable = false
        self.mailMessage!.backgroundColor = UIColor.clearColor()
        self.mailMessage!.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0)
        self.mailMessage!.textColor = UIColor.grayColor()
        self.mailMessage!.userInteractionEnabled = false
        self.indicatorView = MailIndicatorView(frame: CGRectMake(0, 0, 10, 10))
        self.indicatorView!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(mailFrom!)
        self.contentView.addSubview(mailMessage!)
        self.contentView.addSubview(mailSubject!)
        self.contentView.addSubview(mailTime!)
        self.contentView.addSubview(indicatorView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftPadding: CGFloat = 25.0
        let topPadding: CGFloat = 3.0
        let textWidth: CGFloat = self.contentView.bounds.size.width - leftPadding * 2
        let dateWidth: CGFloat = 40
        self.mailFrom!.frame = CGRectMake(leftPadding, topPadding, textWidth, 20)
        self.mailSubject!.frame = CGRectMake(leftPadding, mailFrom!.frame.origin.y + mailFrom!.frame.size.height + topPadding, textWidth - dateWidth, 17)
        let messageHeight: CGFloat = self.contentView.bounds.size.height - (mailSubject!.frame.origin.y + mailSubject!.frame.size.height) - topPadding * 2
        self.mailMessage!.frame = CGRectMake(leftPadding, mailSubject!.frame.origin.y + mailSubject!.frame.size.height + topPadding, textWidth, messageHeight)
        var frame: CGRect = mailFrom!.frame
        frame.origin.x = self.contentView.frame.size.width - leftPadding - dateWidth
        frame.size.width = dateWidth
        self.mailTime!.frame = frame
        self.indicatorView!.center = CGPointMake(leftPadding * 0.5, mailFrom!.frame.origin.y + mailFrom!.frame.size.height * 0.5)
    }
}