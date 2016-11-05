
import Foundation
import UIKit

@objc open class PinTextView: UITextView, UITextViewDelegate {
    
    open var maxLength = 0
    
    open var maxHeight: CGFloat = 0
    
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
    
    fileprivate func commonInit() {
        
        delegate = self
        isScrollEnabled = false
        contentMode = .redraw
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func keyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: duration, animations: {
                self.frame.origin.y = self.superview!.frame.height - keyboardSize.height - self.frame.size.height
            })
        }
    }
    
    // Trim white space and new line characters when end editing.
    func textDidEndEditing(_ notification: Notification) {
        //guard notification.object === self else { return }
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        autoHeight()
        setNeedsDisplay()
    }
    
    // Limit the length of text
    func textDidChange(_ notification: Notification) {
        //guard notification.object === self else { return }
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
        
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.y -= offset
            })
        } else {
            self.frame.origin.y -= offset
        }
    }
}
