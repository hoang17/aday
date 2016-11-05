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
    
    func loadPlayer(_ filePath: String) {
        let fileUrl = URL(fileURLWithPath: filePath)
        player = AVPlayer(url: fileUrl)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }
    
    func playing() -> Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    func play(){
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    func pause(){
        player?.pause()
    }
}

class MiniPlayer: PlayerView {
    
    var fileName: String!
    var filePath: String!

    var task: FIRStorageDownloadTask?
    var playcallback: (()->())?
    var playcompletion: (()->())?
    
    convenience init(clip: ClipModel, frame: CGRect) {
        self.init(frame: frame)
        
        self.fileName = clip.fname
        //print("*** init  : " + fileName)
        self.filePath = NSTemporaryDirectory() + clip.fname
        self.backgroundColor = UIColor.clear

        let resource = ImageResource(downloadURL: URL(string: clip.thumb)!, cacheKey: clip.id)
        let thumbImg = UIImageView(frame: frame)
        thumbImg.backgroundColor = UIColor.clear
        thumbImg.contentMode = .scaleAspectFill
        thumbImg.kf.setImage(with: resource)
        addSubview(thumbImg)

        if FileManager.default.fileExists(atPath: filePath) {
            loadPlayer()
        } else {
            download()
        }
    }
    
    func download() {
        
        let indicator = DGActivityIndicatorView(type: .ballClipRotate, tintColor: UIColor.white, size: 30.0)
        indicator?.size = CGSize(width: 50.0, height: 50.0)
        indicator?.center = center
        addSubview(indicator!)
        indicator?.startAnimating()
        
        //let ai = MRCircularProgressView()
        //ai.size = CGSize(width: 90.0, height: 90.0)
        //ai.tintColor = UIColor(white: 1, alpha: 0.8)
        //ai.center = view.center
        //ai.lineWidth = 5
        //ai.borderWidth = 1
        //view.addSubview(ai)
        
        if let task = UploadHelper.sharedInstance.downloadClip(fileName) {
            task.observe(.success){ snapshot in
                
                //print("File downloaded \(self.fileName)")
                indicator?.removeFromSuperview()
                //ai.removeFromSuperview()
                self.loadPlayer()
                self.playcallback?()
            }
            task.observe(.failure) { snapshot in
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
            indicator?.removeFromSuperview()
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
    
    func play(_ completion: (()->())?) {
        
        playcompletion = completion
        
        if player != nil {
            doplay()
        } else {
            playcallback = doplay
        }
    }
    
    func doplay(){
        super.play()
        NotificationCenter.default.addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
    }
    
    override func pause() {
        
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
        
        //task?.removeAllObservers()
        playcallback = nil
        playcompletion = nil
        task = nil
        super.pause()
    }

    deinit {
        //print("~~~ deinit: " + fileName)
        NotificationCenter.default.removeObserver(self)
        //task?.removeAllObservers()
        //player?.replaceCurrentItemWithPlayerItem(nil)
    }
    
    func playerDidFinishPlaying(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)

        playcompletion?()
        task?.removeAllObservers()
        playcallback = nil
        playcompletion = nil
        task = nil
    }
}

class ClipPlayer : MiniPlayer {
}

class ClipThumbnail: UIView {
    var img: UIImageView!
    let textField = PinTextLabel()
    var dateLabel = UILabel()
    
    init(clip: ClipModel, frame: CGRect) {
        super.init(frame: frame)
        img = UIImageView(frame:frame)
        img.contentMode = .scaleAspectFill
        let resource = ImageResource(downloadURL: URL(string: clip.thumb)!, cacheKey: clip.id)
        img.kf.setImage(with: resource)
        
        if clip.txt == "" {
            textField.isHidden = true
        }
        else {
            textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            textField.textColor = UIColor.white
            textField.font = UIFont.systemFont(ofSize: 10)
            textField.textAlignment = NSTextAlignment.center
            //textField.height = 20
            textField.width = frame.width
            textField.isUserInteractionEnabled = false
            textField.text = clip.txt
            textField.autoHeight(false)
            textField.center.y =  frame.height * CGFloat(clip.y)
        }
        dateLabel.origin = CGPoint(x: 8, y: 8)
        dateLabel.text = (Date(timeIntervalSince1970: clip.date) as NSDate).shortTimeAgoSinceNow()
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
