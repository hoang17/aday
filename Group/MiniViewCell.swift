//
//  MiniViewCell.swift
//  Group
//
//  Created by Hoang Le on 9/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MiniViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class Player: UIView {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var thumb: UIImage!
    
    init(playerItem: AVPlayerItem, frame: CGRect) {
        super.init(frame: frame)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }
    
    init(filePath: String, frame: CGRect) {
        super.init(frame: frame)
        let fileUrl = NSURL(fileURLWithPath: filePath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func playing() -> Bool {
        return player.rate != 0 && player.error == nil
    }
    
    func play(){
        player.seekToTime(kCMTimeZero)
        player.play()
    }
    
    func pause(){
        player.pause()
        player.seekToTime(kCMTimeZero)
    }
}

class  ClipPlayer : Player {
    
    init(clip: Clip) {
        let filePath = NSTemporaryDirectory() + clip.fname
        super.init(filePath: filePath, frame: UIScreen.mainScreen().bounds)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MiniPlayer: NSObject {
    let img: UIImageView!
    let textField = UITextField()
    var dateLabel = UILabel()
    
    init(clip: Clip, frame: CGRect) {
        
        let filename = NSTemporaryDirectory() + clip.fname + ".jpg"
        let image = UIImage(contentsOfFile: filename)
        img = UIImageView(image: image)
        img.frame = frame
        
        if clip.txt == "" {
            textField.hidden = true
        }
        else {
            textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            textField.textColor = UIColor.whiteColor()
            textField.font = UIFont.systemFontOfSize(10)
            textField.textAlignment = NSTextAlignment.Center
            textField.height = 20
            textField.width = frame.width
            textField.userInteractionEnabled = false
            textField.text = clip.txt
            textField.center.y =  frame.height * clip.y
        }
        dateLabel.origin = CGPoint(x: 8, y: 8)
        dateLabel.text = NSDate(timeIntervalSince1970: clip.date).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: 14)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.8)
        dateLabel.font = UIFont(name: "OpenSans", size: 11.0)
    }    
}