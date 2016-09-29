//
//  PlayerCalloutView.swift
//  Group
//
//  Created by Hoang Le on 9/28/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Kingfisher
import FirebaseStorage

class PlayerCalloutView: UIView {
    
    var locationName = UILabel()
    var locationSub = UILabel()
    var clips = [Clip]()
    var playIndex = 0
    var players = [Int:ClipCalloutView]()
    
    init(clips: [Clip], frame: CGRect) {
        super.init(frame: frame)
        
        locationName.font = UIFont.systemFontOfSize(12)
        locationName.textAlignment = NSTextAlignment.Center
        locationName.height = 28
        locationName.userInteractionEnabled = false
        locationName.text = clips[playIndex].lname
        locationName.y = 162
        locationName.backgroundColor = UIColor.whiteColor()
        locationName.layer.cornerRadius = 5
        locationName.layer.masksToBounds = true
        locationName.clipsToBounds = true
        locationName.layer.borderColor = UIColor.lightGrayColor().CGColor;
        locationName.layer.borderWidth = 0.5
        
        let atxt = locationName.attributedText!.mutableCopy() as! NSMutableAttributedString
        locationName.width = atxt.size().width + 20
        locationName.x = (90 - locationName.width)/2
        
        self.addSubview(locationName)
        
        self.clips = clips
        self.backgroundColor = UIColor.clearColor()
        play()        
    }
    
    func playPrevClip(){
        playIndex -= 1
        if playIndex >= 0 {
            play()
        }
    }
    
    func playNextClip(){
        playIndex += 1
        if playIndex >= clips.count {
            playIndex = 0
        }
        play()
    }
    
    func play() {
        if players[playIndex] == nil {
            let clipCallOut = ClipCalloutView(clip: clips[playIndex], frame: CGRect(x: 0,y: 0, width: 90,height: 160))
            self.addSubview(clipCallOut)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object:clipCallOut.miniPlayer.player.currentItem)
            players[playIndex] = clipCallOut
        }
        players[playIndex]!.miniPlayer.play()
        self.bringSubviewToFront(players[playIndex]!)
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        if playIndex+1 < clips.count {
            play()
        } else {
            playIndex = 0
            players[playIndex]?.miniPlayer.pause()
            self.bringSubviewToFront(players[playIndex]!)
        }
    }
    
    func pause() {
        players[playIndex]?.miniPlayer.pause()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
