//
//  ClipHelper.swift
//  Pinly
//
//  Created by Hoang Le on 10/3/16.
//  Copyright © 2016 ping. All rights reserved.
//

import FirebaseStorage

class ClipHelper {
    
    static var sharedInstance = ClipHelper()
    
    func downloadClips(clips: [Clip]){
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
        
        for clip in clips {
            
            let fileName = clip.fname
            
            // Check if file not existed then download
            let filePath = NSTemporaryDirectory() + fileName;
            if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                
                print("Downloading file \(fileName)...")
                // File not existed then download
                let localURL = NSURL(fileURLWithPath: filePath)
                gs.child(fileName).writeToFile(localURL) { (URL, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print("File downloaded " + fileName)
                    }
                }
            }
        }
    }
}
