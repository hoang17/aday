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
    var player: AVPlayer?
    
    convenience init(playerItem: AVPlayerItem, frame: CGRect) {
        self.init(frame: frame)
        
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
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
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }
    
    func playing() -> Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    func play(){
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    func pause(){
        player?.pause()
    }
}

class MiniPlayer : PlayerView {
    
    var fileName: String!
    var filePath: String!

    var task: FIRStorageDownloadTask?
    var playcallback: (()->())?
    
    convenience init(clip: ClipModel, frame: CGRect) {
        self.init(frame: frame)
        
        self.fileName = clip.fname
        self.filePath = NSTemporaryDirectory() + clip.fname
        self.backgroundColor = UIColor.clearColor()

        let resource = Resource(downloadURL: NSURL(string: clip.thumb)!, cacheKey: clip.id)
        let thumbImg = UIImageView(frame: frame)
        thumbImg.backgroundColor = UIColor.clearColor()
        thumbImg.contentMode = .ScaleAspectFill
        thumbImg.kf_setImageWithResource(resource)
        addSubview(thumbImg)

        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            loadPlayer()
        } else {
            download()
        }
    }
    
    func download() {
        
        let indicator = DGActivityIndicatorView(type: .BallClipRotate, tintColor: UIColor.whiteColor(), size: 30.0)
        indicator.size = CGSize(width: 50.0, height: 50.0)
        indicator.center = center
        addSubview(indicator)
        indicator.startAnimating()
        
        //let ai = MRCircularProgressView()
        //ai.size = CGSize(width: 90.0, height: 90.0)
        //ai.tintColor = UIColor(white: 1, alpha: 0.8)
        //ai.center = view.center
        //ai.lineWidth = 5
        //ai.borderWidth = 1
        //view.addSubview(ai)
        
        if let task = UploadHelper.sharedInstance.downloadClip(fileName) {
            task.observeStatus(.Success){ snapshot in
                
                //print("File downloaded \(self.fileName)")
                indicator.removeFromSuperview()
                //ai.removeFromSuperview()
                self.loadPlayer()
                self.playcallback?()
            }
            task.observeStatus(.Failure) { snapshot in
                guard let storageError = snapshot.error else { return }
                print(storageError)
            }
            //task?.observeStatus(.Progress) { snapshot in
            //    if let completed = snapshot.progress?.completedUnitCount {
            //        let total = snapshot.progress!.totalUnitCount
            //        let percentComplete : Float = total == 0 ? 0 : Float(completed)/Float(total)
            //        print(percentComplete)
            //        ai.setProgress(percentComplete, animated: true)
            //    }
            //}
        } else {
            indicator.removeFromSuperview()
            //ai.removeFromSuperview()
            self.loadPlayer()
            self.playcallback?()
        }
    }

    func loadPlayer() {
        if player == nil {
            super.loadPlayer(filePath)
        }
    }
    
    func play(completion: (AVPlayerItem?)->()) {
        
        if player != nil {
            super.play()
            completion(player?.currentItem)
        } else {
            playcallback = {
                super.play()
                completion(self.player?.currentItem)
            }
        }
    }
    
    override func pause() {
        //print("pause: " + fileName)
        task?.removeAllObservers()
        playcallback = nil
        task = nil
        super.pause()
    }
    
    deinit {
        //print("deinit: " + fileName)
        task?.removeAllObservers()
        player?.replaceCurrentItemWithPlayerItem(nil)
        playcallback = nil
        task = nil
        player = nil
    }
}

class ClipPlayer : MiniPlayer {
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
