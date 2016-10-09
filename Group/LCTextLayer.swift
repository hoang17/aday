//
//  LCTextLayer
//  Pinly
//
//  Created by Hoang Le on 10/9/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class LCTextLayer : CATextLayer {
    
    // Vertical center align text
    override func drawInContext(ctx: CGContext) {
        let height = self.frame.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/5
        CGContextSaveGState(ctx)
        CGContextTranslateCTM(ctx, 0.0, yDiff)
        super.drawInContext(ctx)
        CGContextRestoreGState(ctx)
    }
}
