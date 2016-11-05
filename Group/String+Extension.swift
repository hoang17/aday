//
//  String+Extension.swift
//  Pinly
//
//  Created by Hoang Le on 9/30/16.
//  Copyright © 2016 ping. All rights reserved.
//

import Foundation

extension String {
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: "\\s", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
    }
        
    func urlencodedString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
