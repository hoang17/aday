//
//  TableViewCell.swift
//  Group
//
//  Created by Hoang Le on 9/11/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    var nameLabel = UILabel()
    var profileImg = UIImageView()
    var clips: [Clip]!
    let cellWidth = 150
    let cellHeight = 266
    weak var controller: UIViewController?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImg.origin = CGPoint(x: 10, y: 15)
        profileImg.size = CGSize(width: 40, height: 40)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
    
        nameLabel.origin = CGPoint(x: 60, y: 15)
        nameLabel.size = CGSize(width: self.width, height: 35)
        nameLabel.textColor = UIColor.blackColor()
//        nameLabel.font = UIFont(name: "SourceSansPro-Bold", size: 13.0)
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 13.0)
//        nameLabel.font = UIFont.boldSystemFontOfSize(13)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 3
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.origin.y = 55
        collectionView.height = 290
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        self.addSubview(profileImg)
        self.addSubview(nameLabel)
        self.addSubview(collectionView)
    }
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clips!.count
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
        
        let clip = clips![indexPath.row]
        if (clip.player == nil){
            clip.player = MiniPlayer(clip: clips![indexPath.row], frame: cell.bounds)
        }
        let mp = clip.player!
        cell.layer.addSublayer(mp.playerLayer)
        cell.addSubview(mp.textField);
        cell.bringSubviewToFront(mp.textField)
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = false
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cameraPlayback = CameraPlaybackController()
        cameraPlayback.clips = self.clips
        cameraPlayback.playerIndex = indexPath.row
        
        cameraPlayback.nameLabel.text = nameLabel.text
        let atxt = cameraPlayback.nameLabel.attributedText!.mutableCopy() as! NSMutableAttributedString
        cameraPlayback.nameLabel.width = atxt.size().width
        cameraPlayback.dateLabel.x = 50 + cameraPlayback.nameLabel.width
        cameraPlayback.profileImg.image = profileImg.image
        
        self.controller!.presentViewController(cameraPlayback, animated: true, completion: nil)
    }
    
}

class MiniPlayer: NSObject {
    var clip: Clip
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    let textField = UITextField()
    
    init(clip: Clip, frame: CGRect) {
        
        self.clip = clip

        let outputPath = NSTemporaryDirectory() + clip.fname
        let fileUrl = NSURL(fileURLWithPath: outputPath)
        player = AVPlayer(URL: fileUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
        //                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
        //                                                         object: player!.currentItem)
        //        player!.play()
        
        if (clip.txt == ""){
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
    }
}