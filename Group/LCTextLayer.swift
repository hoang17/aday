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
    override func draw(in ctx: CGContext) {
        let height = self.frame.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/5
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
