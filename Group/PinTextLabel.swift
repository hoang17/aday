
import Foundation
import UIKit

@objc open class PinTextLabel: UITextView {
    
    open var maxLength = 0
    
    open var maxHeight: CGFloat = 0
    
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
                self.frame.origin.y = self.frame.origin.y - offset
            })
        }
        else{
            self.frame.origin.y = self.frame.origin.y - offset
        }
    }
}
