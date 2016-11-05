//
//  CommentTextView.swift
//  Pinly
//
//  Created by Hoang Le on 11/4/16.
//  Copyright © 2016 ping. All rights reserved.
//


import Foundation
import UIKit

@objc open class CommentTextView: UIView {
    
    open var commentField: CommentTextField!
    
    open var sendButton: UIButton!
    
    open var sendCallback: (()->Void)?
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 34))
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        commentField = CommentTextField()
        commentField.width = frame.width-40
        commentField.height = frame.height
        commentField.backgroundColor = UIColor.clear
        commentField.textColor = UIColor.white
        commentField.font = UIFont.systemFont(ofSize: 16.0)
        commentField.textAlignment = NSTextAlignment.left
        commentField.placeHolder = "Write a comment..."
        commentField.placeHolderColor = UIColor(white: 1, alpha: 0.5)
        
        commentField.text = ""
        commentField.returnKeyType = UIReturnKeyType.default
        commentField.isUserInteractionEnabled = true
        self.addSubview(commentField)
        
        commentField.offsetCallback = { [weak self] (offset) in
            self?.frame.size.height += offset
            UIView.animate(withDuration: 0.3, animations: {
                self?.frame.origin.y -= offset
            })
        }
        
        let sendIcon = UIImage(named: "ic_send") as UIImage?
        sendButton = UIButton(type: .system)
        sendButton.tintColor = UIColor(white: 1, alpha: 1)
        sendButton.backgroundColor = UIColor.clear
        sendButton.setImage(sendIcon, for: UIControlState())
        sendButton.addTarget(self, action: #selector(sendHandle), for: .touchUpInside)
        self.addSubview(sendButton)
        sendButton.snp_makeConstraints { [weak self] (make) -> Void in
            make.bottom.equalTo(self!).offset(-5)
            make.right.equalTo(self!).offset(-5)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // On return done editing
    func sendHandle(){
        commentField.text = commentField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sendCallback?()
    }
    
    func keyboardNotification(_ notification: Notification) {        
        guard let superview = self.superview else {
            return
        }
        
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: duration, animations: {
                self.frame.origin.y = superview.frame.height - keyboardSize.height - self.frame.size.height
            })
        }
    }
 
    deinit {
        //print("deinit comment box")
        NotificationCenter.default.removeObserver(self)
    }
}

@objc open class CommentTextField: UITextView, UITextViewDelegate {
    
    open var maxLength = 0
    
    open var maxHeight: CGFloat = 0
    
    open var offsetCallback: ((_ offset: CGFloat)-> Void)?
    
    // Placeholder properties
    // Need to set both placeHolder and placeHolderColor in order to show placeHolder in the textview
    open var placeHolder: NSString? {
        didSet { setNeedsDisplay() }
    }
    
    open var placeHolderColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    open var placeHolderLeftMargin: CGFloat = 5 {
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
    
    fileprivate func commonInit(_ obKeyboard: Bool = true) {
        
        delegate = self
        isScrollEnabled = false
        contentMode = .redraw
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    // Show placeholder
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            guard let placeHolderColor = placeHolderColor else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRect(x: textContainerInset.left + placeHolderLeftMargin,
                                  y: textContainerInset.top,
                                  width: frame.size.width - textContainerInset.left - textContainerInset.right,
                                  height: frame.size.height)
            
            var attributes = [
                NSForegroundColorAttributeName: placeHolderColor,
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            if let font = font {
                attributes[NSFontAttributeName] = font
            }
            
            placeHolder.draw(in: rect, withAttributes: attributes)
        }
    }
    
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard maxHeight > 0 else { return true }
        
        let newText = textView.attributedText!.mutableCopy() as! NSMutableAttributedString
        newText.replaceCharacters(in: range, with: text)
        let maxSize = CGSize(width: textView.frame.size.width - 15, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = newText.string.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font!], context: nil)
        return maxHeight >= boundingRect.size.height+20
    }
    
    // Trim white space and new line characters when end editing.
    func textDidEndEditing(_ notification: Notification) {
        guard notification.object === self else { return }
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        autoHeight()
        setNeedsDisplay()
    }
    
    // Limit the length of text
    func textDidChange(_ notification: Notification) {
        guard notification.object === self else { return }
        autoHeight()
        setNeedsDisplay()
    }
    
    open func autoHeight(_ animation: Bool = true){
        if maxLength > 0 && text.characters.count > maxLength {
            let endIndex = text.index(text.startIndex, offsetBy: maxLength)
            text = text.substring(to: endIndex)
            undoManager?.removeAllActions()
        }
        
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
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
        
        offsetCallback?(offset)
    }
    
    deinit {
        //print("deinit comment field")
        NotificationCenter.default.removeObserver(self)
    }

}
