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

    var player: AVPlayer!
    
    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceiveNotification(notification: UNNotification) {
        
        self.label?.text = notification.request.content.body
        
        print("content notification:", self.label?.text)
        
        let attachment = notification.request.content.attachments[0]
        player = AVPlayer(URL: attachment.URL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        player.actionAtItemEnd = .None
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
    }

    // Auto rewind player
    func playerDidFinishPlaying(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
