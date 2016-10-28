//
//  PlayerView.swift
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
import DGActivityIndicatorView

class PlayerView: UIView {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    //var thumb: UIImage!
    
    convenience init(playerItem: AVPlayerItem, frame: CGRect) {
        self.init(frame: frame)
        
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }
    
    convenience init(filePath: String, frame: CGRect) {
        self.init(frame: frame)
        loadPlayer(filePath)
    }
    
    func loadPlayer(filePath: String) {
        let fileUrl = NSURL(fileURLWithPath: filePath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
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

class ClipPlayer : MiniPlayer {    
}

class MiniPlayer : PlayerView {
    
    var pid: String!
    var fileName: String!
    var thumbUrl: String!
    var filePath: String!
    
    var selector: ((NSNotification) -> ())?
    var task: FIRStorageDownloadTask?
    var closed = false
    var playerLoaded = false
    var playQueue = false
    
    convenience init(clip: ClipModel, frame: CGRect, selector: ((NSNotification) -> ())?) {
        self.init(frame: frame)
        
        self.pid = clip.id
        self.fileName = clip.fname
        self.thumbUrl = clip.thumb
        self.filePath = NSTemporaryDirectory() + clip.fname
        self.selector = selector
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            loadPlayer()
        } else {
            download()
        }
    }
    
    func download() {
        
        let resource = Resource(downloadURL: NSURL(string: thumbUrl)!, cacheKey: pid)
        let thumbImg = UIImageView(frame: frame)
        thumbImg.contentMode = .ScaleAspectFill
        thumbImg.kf_setImageWithResource(resource)
        thumbImg.hidden = false
        addSubview(thumbImg)
        
        let indicator = DGActivityIndicatorView(type: .BallClipRotate, tintColor: UIColor.whiteColor(), size: 30.0)
        indicator.size = CGSize(width: 50.0, height: 50.0)
        indicator.center = center
        addSubview(indicator)
        indicator.startAnimating()
        
        //            let ai = MRCircularProgressView()
        //            ai.size = CGSize(width: 90.0, height: 90.0)
        //            ai.tintColor = UIColor(white: 1, alpha: 0.8)
        //            ai.center = view.center
        //            ai.lineWidth = 5
        //            ai.borderWidth = 1
        //            view.addSubview(ai)
        
        task = UploadHelper.sharedInstance.downloadClip(fileName, callback: true)
        task?.observeStatus(.Success){ (snapshot) in
            
            print("File downloaded \(self.fileName)")
            indicator.removeFromSuperview()
            
            if self.closed {
                return
            }
            
            self.loadPlayer()
            if self.playQueue {
                super.play()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                                                 name: AVPlayerItemDidPlayToEndTimeNotification,
                                                                 object: self.player.currentItem)
            }
            
            // ai.removeFromSuperview()
            // self.player.removeFromSuperview()
            // self.player = self.playerAtIndex(self.playIndex)
            // thumbImg.removeFromSuperview()
        }
        task?.observeStatus(.Failure) { (snapshot) in
            guard let storageError = snapshot.error else { return }
            print(storageError)
        }
        //            task?.observeStatus(.Progress) { (snapshot) in
        //                if let completed = snapshot.progress?.completedUnitCount {
        //                    let total = snapshot.progress!.totalUnitCount
        //                    let percentComplete : Float = total == 0 ? 0 : Float(completed)/Float(total)
        //                    print(percentComplete)
        //                    ai.setProgress(percentComplete, animated: true)
        //                }
        //            }
    }

    func loadPlayer() {
        if !playerLoaded {
            playerLoaded = true
            super.loadPlayer(filePath)
        }
    }
    
    override func play() {
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            super.play()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object: self.player.currentItem)
        } else {
            playQueue = true
        }
    }
    
    override func pause(){
        task?.removeAllObservers()
        playQueue = false
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object: self.player.currentItem)
        if player == nil {
            return
        }
        super.pause()
    }
    
    func close(){
        task?.removeAllObservers()
        closed = true
        pause()
    }
    
    func playerDidFinishPlaying(notification: NSNotification){
        self.selector?(notification)
    }
    
}

class ClipThumbnail: UIView {
    var img: UIImageView!
    let textField = UITextField()
    var dateLabel = UILabel()
    
    init(clip: ClipModel, frame: CGRect) {
        super.init(frame: frame)
        img = UIImageView(frame:frame)
        img.contentMode = .ScaleAspectFill
        let resource = Resource(downloadURL: NSURL(string: clip.thumb)!, cacheKey: clip.id)
        img.kf_setImageWithResource(resource)
        
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
            textField.center.y =  frame.height * CGFloat(clip.y)
        }
        dateLabel.origin = CGPoint(x: 8, y: 8)
        dateLabel.text = NSDate(timeIntervalSince1970: clip.date).shortTimeAgoSinceNow()
        dateLabel.size = CGSize(width: 50, height: 14)
        dateLabel.textColor = UIColor(white: 1, alpha: 0.8)
        dateLabel.font = UIFont(name: "OpenSans", size: 11.0)
        
        addSubview(img)
        addSubview(textField)
        addSubview(dateLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
