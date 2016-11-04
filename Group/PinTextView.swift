
import Foundation
import UIKit

@objc public class PinTextView: UITextView, UITextViewDelegate {
    
    public var maxLength = 0
    
    public var maxHeight: CGFloat = 0
    
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
    
    private func commonInit() {
        
        delegate = self
        scrollEnabled = false
        contentMode = .Redraw
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidEndEditing), name: UITextViewTextDidEndEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidChange), name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)
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
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            UIView.animateWithDuration(duration, animations: {
                self.frame.origin.y = self.superview!.frame.height - keyboardSize.height - self.frame.size.height
            })
        }
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
        
        if animation {
            UIView.animateWithDuration(0.3, animations: {
                self.frame.origin.y -= offset
            })
        } else {
            self.frame.origin.y -= offset
        }
    }
}
