
import Foundation
import UIKit

@objc public protocol PinTextViewDelegate: UITextViewDelegate {
    optional func textViewDidChangeHeight(height: CGFloat)
}

@objc public class PinTextView: UITextView {
    
    // Maximum length of text. 0 means no limit.
    public var maxLength = 0
    
    // Maximm height of the textview
    public var maxHeight = CGFloat(0)
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.contentMode = .Redraw
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidEndEditing), name: UITextViewTextDidEndEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textDidChange), name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        if notification.object === self {
            text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            textDidChange(notification)
            //setNeedsDisplay()
        }
    }
    
    // Limit the length of text
    func textDidChange(notification: NSNotification) {
        
        guard notification.object === self else { return }
        
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
        contentSize.height = height
        frame.size.height = height
        
        UIView.animateWithDuration(0.3, animations: {
            self.frame.origin.y = self.frame.origin.y - offset
        })
    }
}
