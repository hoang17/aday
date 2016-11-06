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
import AVKit
import AVFoundation

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceiveNotification(notification: UNNotification) {
        
        self.label?.text = notification.request.content.body
        
        print("content notification:", self.label?.text)
        
        let attachment = notification.request.content.attachments[0]
        let player = AVPlayer(URL: attachment.URL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        player.play()
    }

}
