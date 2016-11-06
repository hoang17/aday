//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Hoang Le on 11/5/16.
//  Copyright © 2016 ping. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI
import AVKit
import AVFoundation

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    var player: AVPlayer!
    
    //@IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceiveNotification(notification: UNNotification) {
        
        //self.label?.text = notification.request.content.body
        
        print("content notification:", notification.request.content.body)
        
        let attachment = notification.request.content.attachments[0]
        player = AVPlayer(URL: attachment.URL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        player.actionAtItemEnd = .None
        player.play()
        
        //if notification.request.content.body != "" {
        //    let textField = UITextView()
        //    textField.text = notification.request.content.body
        //    textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        //    textField.textColor = UIColor.whiteColor()
        //    textField.font = UIFont.systemFontOfSize(16.0)
        //    textField.textAlignment = NSTextAlignment.Center
        //    textField.frame.size.height = 34
        //    textField.frame.size.width = view.frame.width
        //    textField.userInteractionEnabled = false
        //    
        //    let size = textField.sizeThatFits(CGSizeMake(textField.frame.width, CGFloat.max))
        //    textField.frame.size.height = size.height
        //    textField.frame.origin.y = view.frame.height - textField.frame.height - 20
        //    view.addSubview(textField)
        //}
        
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
