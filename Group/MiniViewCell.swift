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
    
    weak var tableCell: TableViewCell!
    var index:Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = false
        self.clipsToBounds = true

        let tap = UITapGestureRecognizer(target:self, action:#selector(tapGesture))
        self.addGestureRecognizer(tap)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func tapGesture(sender:UITapGestureRecognizer){
        
        let location = sender.locationInView(self)
        
        if location.y > 0.25*self.height {
            tableCell.play(index)
        } else {
            tableCell.playMini(index)
        }
    }
    
}

class MiniPlayer: NSObject {
    var clip: Clip
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    let textField = UITextField()
    var dateLabel = UILabel()
    
    init(clip: Clip, frame: CGRect) {
        
        self.clip = clip
        
        let outputPath = NSTemporaryDirectory() + clip.fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = UIScreen.mainScreen().bounds
        
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
        //        dateLabel.font = UIFont.systemFontOfSize(11)
        
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