
import Foundation
import UIKit

@objc public class PinTextLabel: UITextView {
    
    public var maxLength = 0
    
    public var maxHeight: CGFloat = 0
    
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
                self.frame.origin.y = self.frame.origin.y - offset
            })
        }
        else{
            self.frame.origin.y = self.frame.origin.y - offset
        }
    }
}
