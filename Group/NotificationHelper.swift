//
//  NotificationCenter.swift
//  Pinly
//
//  Created by Hoang Le on 10/31/16.
//  Copyright © 2016 ping. All rights reserved.
//

import LNNotificationsUI

class NotificationHelper {

    static let sharedInstance = NotificationHelper()

    func present(userInfo: [NSObject : AnyObject]) {
        let aps = userInfo["aps"]
        guard let alert = aps?["alert"] else {
            return
        }
        
        let title: String = alert?["title"] as? String ?? "Pinly"
        let msg: String = alert?["body"] as? String ?? (alert as? String ?? "")
        
        let notification = LNNotification(message: msg)
        notification.title = title
        notification.soundName = "Tritone.mp3"
        
        if let uid = userInfo["from"] as? String {
            if let user = AppDelegate.realm.objectForPrimaryKey(UserModel.self, key: uid){
                let imageview = UIImageView()
                imageview.kf_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(user.fb)/picture?type=large&return_ssl_resources=1"))
                notification.icon = imageview.image
            }
        }
        
        notification.defaultAction = LNNotificationAction(title: "View", handler: { action in
            let alertView = UIAlertView(title: notification.title, message: "Notification was tapped!", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        })
        
        LNNotificationCenter.defaultCenter().presentNotification(notification, forApplicationIdentifier: "Pinly")
    }
}
