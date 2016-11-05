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

    func present(_ userInfo: [AnyHashable: Any]) {
        let aps = userInfo["aps"] as? NSDictionary
        guard let alert = aps?["alert"] as? NSDictionary else {
            return
        }
        
        let title: String = alert["title"] as? String ?? "Pinly"
        let msg: String = alert["body"] as? String ?? "Message is empty"
        
        let notification = LNNotification(message: msg)
        notification?.title = title
        notification?.soundName = "Tritone.mp3"
        
        if let uid = userInfo["from"] as? String {
            if let user = AppDelegate.realm.object(ofType: UserModel.self, forPrimaryKey: uid){
                let imageview = UIImageView()
                imageview.kf.setImage(with: URL(string: "https://graph.facebook.com/\(user.fb)/picture?type=large&return_ssl_resources=1"))
                notification?.icon = imageview.image
            }
        }
        
        notification?.defaultAction = LNNotificationAction(title: "View", handler: { action in
            let alertView = UIAlertView(title: notification?.title, message: "Notification was tapped!", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        })
        
        LNNotificationCenter.default().present(notification, forApplicationIdentifier: "Pinly")
    }
}
