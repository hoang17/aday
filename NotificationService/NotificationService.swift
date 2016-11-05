//
//  NotificationService.swift
//  NotificationService
//
//  Created by Hoang Le on 11/1/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        func failEarly() {
            print("notification has no attachment")
            contentHandler(request.content)
        }
        
        guard let bestAttemptContent = bestAttemptContent,
              let fname = bestAttemptContent.userInfo["fname"] as? String,
              let furlstring = bestAttemptContent.userInfo["furl"] as? String,
              let furl = NSURL(string: furlstring) else { return failEarly() }
        
        
        // Modify the notification content here...
        //bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
        
        let filePath = NSTemporaryDirectory() + fname
        let localURL = URL(fileURLWithPath: filePath)

        if FileManager.default.fileExists(atPath: filePath) {
            
            guard let attachment = try? UNNotificationAttachment(identifier: "video", url: localURL as URL, options: nil) else {
                return failEarly()
            }
            
            bestAttemptContent.attachments = [attachment]
            return contentHandler(bestAttemptContent)
        }
        
        print("downloading \(fname)")
        let dataTask = URLSession.shared.dataTask(with: furl as URL) { (data, response, error) in
            do {
                try data?.write(to: localURL, options: .atomic)
            } catch {
                print(error)
            }
            guard let attachment = try? UNNotificationAttachment(identifier: "video", url: localURL as URL, options: nil) else {
                return failEarly()
            }
            
            bestAttemptContent.attachments = [attachment]
            contentHandler(bestAttemptContent)
        }
        dataTask.resume()

        
//        let filePath = NSTemporaryDirectory() + fname
//        // Only download if file not existed
//        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
//            let storage = FIRStorage.storage()
//            let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
//            let localURL = NSURL(fileURLWithPath: filePath)
//            gs.child(fname).writeToFile(localURL){ (url, error) in
//                guard error == nil else {
//                    print(error)
//                    contentHandler(bestAttemptContent)
//                    return
//                }
//                
//                print("downloaded \(fname)")
//                let localURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + fname)
//                if let attachment = try? UNNotificationAttachment(identifier: "pin", URL: localURL, options:nil) {
//                    bestAttemptContent.attachments = [attachment]
//                }
//                contentHandler(bestAttemptContent)
//            }
//        }
        
//        // Download the attachment
//        URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
//            if let location = location {
//                // Move temporary file to remove .tmp extension
//                let tmpDirectory = NSTemporaryDirectory()
//                let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
//                let tmpUrl = URL(string: tmpFile)!
//                try! FileManager.default.moveItem(at: location, to: tmpUrl)
//                
//                // Add the attachment to the notification content
//                if let attachment = try? UNNotificationAttachment(identifier: "video", url: tmpUrl, options:nil) {
//                    self.bestAttemptContent?.attachments = [attachment]
//                }
//            }
//            // Serve the notification content
//            self.contentHandler!(self.bestAttemptContent!)
//        }.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
