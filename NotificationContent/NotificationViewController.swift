//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Hoang Le on 11/5/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    public func didReceiveNotification(notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

}
