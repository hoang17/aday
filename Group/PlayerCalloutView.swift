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
    var clips = [ClipModel]()
    var playIndex = 0
    var clipCallout: ClipCalloutView?
    
    convenience init(clips: [ClipModel], frame: CGRect) {
        self.init(frame: frame)
        
        locationName.font = UIFont.systemFontOfSize(12)
        locationName.textAlignment = NSTextAlignment.Center
        locationName.y = 194
        locationName.height = 28
        locationName.userInteractionEnabled = true
        locationName.backgroundColor = UIColor.whiteColor()
        locationName.layer.cornerRadius = 5
        locationName.layer.masksToBounds = true
        locationName.clipsToBounds = true
        locationName.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationName.layer.borderWidth = 0.5
        locationName.text = clips[playIndex].lname
        
        let atxt = locationName.attributedText!.mutableCopy() as! NSMutableAttributedString
        locationName.width = atxt.size().width + 20
        locationName.x = (frame.width - locationName.width)/2
        
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
        if locationName.text != clips[playIndex].lname {
            locationName.text = clips[playIndex].lname
            let atxt = locationName.attributedText!.mutableCopy() as! NSMutableAttributedString
            locationName.width = atxt.size().width + 20
            locationName.x = (frame.width - locationName.width)/2
        }
        
        clipCallout?.removeFromSuperview()
        clipCallout = ClipCalloutView(clip: clips[playIndex], frame: CGRect(x: 0,y: 0, width: 108,height: 192))
        self.addSubview(clipCallout!)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(playerDidFinishPlaying),
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object:clipCallout?.miniPlayer.player?.currentItem)
        
        clipCallout?.miniPlayer.play()
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        if playIndex+1 < clips.count {
            playNextClip()
        } else {
            playIndex = 0
            pause()
        }
    }
    
    func pause() {
        
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object:clipCallout?.miniPlayer.player?.currentItem)
        
        clipCallout?.miniPlayer.pause()
    }
    
    func close(){
        clipCallout?.miniPlayer.stop()
        clipCallout?.miniPlayer = nil
        clipCallout = nil
    }
}
