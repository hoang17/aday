//
//  CommentTextView.swift
//  Pinly
//
//  Created by Hoang Le on 11/4/16.
//  Copyright © 2016 ping. All rights reserved.
//


import Foundation
import UIKit

@objc public class CommentTextView: UIView {
    
    public var commentField: CommentTextField!
    
    public var sendButton: UIButton!
    
    public var sendCallback: (()->Void)?
    
    init(){
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 34))
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        
        commentField = CommentTextField()
        commentField.width = frame.width-40
        commentField.height = frame.height
        commentField.backgroundColor = UIColor.clearColor()
        commentField.textColor = UIColor.whiteColor()
        commentField.font = UIFont.systemFontOfSize(16.0)
        commentField.textAlignment = NSTextAlignment.Left
        commentField.placeHolder = "Write a comment..."
        commentField.placeHolderColor = UIColor(white: 1, alpha: 0.5)
        
        commentField.text = ""
        commentField.returnKeyType = UIReturnKeyType.Default
        commentField.userInteractionEnabled = true
        self.addSubview(commentField)
        
        commentField.offsetCallback = { (offset) in
            self.frame.size.height += offset
            UIView.animateWithDuration(0.3, animations: {
                self.frame.origin.y -= offset
            })
        }
        
        let sendIcon = UIImage(named: "ic_send") as UIImage?
        sendButton = UIButton(type: .System)
        sendButton.tintColor = UIColor(white: 1, alpha: 1)
        sendButton.backgroundColor = UIColor.clearColor()
        sendButton.setImage(sendIcon, forState: .Normal)
        sendButton.addTarget(self, action: #selector(sendHandle), forControlEvents: .TouchUpInside)
        self.addSubview(sendButton)
        sendButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-5)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    // On return done editing
    func sendHandle(){
        commentField.text = commentField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        sendCallback?()
    }
    
    func keyboardNotification(notification: NSNotification) {        
        guard let superview = self.superview else {
            return
        }
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animateWithDuration(duration, animations: {
                self.frame.origin.y = superview.frame.height - keyboardSize.height - self.frame.size.height
            })
        }
    }
 
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

@objc public class CommentTextField: UITextView, UITextViewDelegate {
    
    public var maxLength = 0
    
    public var maxHeight: CGFloat = 0
    
    public var offsetCallback: ((offset: CGFloat)-> Void)?
    
    // Placeholder properties
    // Need to set both placeHolder and placeHolderColor in order to show placeHolder in the textview
    public var placeHolder: NSString? {
        didSet { setNeedsDisplay() }
    }
    
    public var placeHolderColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    public var placeHolderLeftMargin: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(obKeyboard: Bool = true) {
        
        delegate = self
        scrollEnabled = false
        contentMode = .Redraw
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidEndEditing), name: UITextViewTextDidEndEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidChange), name: UITextViewTextDidChangeNotification, object: self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Show placeholder
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            guard let placeHolderColor = placeHolderColor else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRectMake(textContainerInset.left + placeHolderLeftMargin,
                                  textContainerInset.top,
                                  frame.size.width - textContainerInset.left - textContainerInset.right,
                                  frame.size.height)
            
            var attributes = [
                NSForegroundColorAttributeName: placeHolderColor,
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            if let font = font {
                attributes[NSFontAttributeName] = font
            }
            
            placeHolder.drawInRect(rect, withAttributes: attributes)
        }
    }
    
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        guard maxHeight > 0 else { return true }
        
        let newText = textView.attributedText!.mutableCopy() as! NSMutableAttributedString
        newText.replaceCharactersInRange(range, withString: text)
        let maxSize = CGSizeMake(textView.frame.size.width - 15, CGFloat.max)
        let boundingRect = newText.string.boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font!], context: nil)
        return maxHeight >= boundingRect.size.height+20
    }
    
    // Trim white space and new line characters when end editing.
    func textDidEndEditing(notification: NSNotification) {
        guard notification.object === self else { return }
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        autoHeight()
        setNeedsDisplay()
    }
    
    // Limit the length of text
    func textDidChange(notification: NSNotification) {
        guard notification.object === self else { return }
        autoHeight()
        setNeedsDisplay()
    }
    
    public func autoHeight(animation: Bool = true){
        if maxLength > 0 && text.characters.count > maxLength {
            let endIndex = text.startIndex.advancedBy(maxLength)
            text = text.substringToIndex(endIndex)
            undoManager?.removeAllActions()
        }
        
        let size = sizeThatFits(CGSizeMake(bounds.size.width, CGFloat.max))
        var height = size.height
        if maxHeight > 0 {
            height = min(size.height, maxHeight)
        }
        let offset = height  - self.frame.size.height
        if offset == 0 {
            return
        }
        contentSize.height = height
        frame.size.height = height
        
        offsetCallback?(offset: offset)
    }
}
