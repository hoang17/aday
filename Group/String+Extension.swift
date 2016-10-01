//
//  String+Extension.swift
//  Pinly
//
//  Created by Hoang Le on 9/30/16.
//  Copyright © 2016 ping. All rights reserved.
//

import Foundation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    }
}
