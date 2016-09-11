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
    var clips: [Clip]?
    let cellWidth = 150
    let cellHeight = 266

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.height = 280
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.backgroundColor = UIColor.clearColor()
        
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
        
        return cell
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
        
        textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        textField.textColor = UIColor.whiteColor()
        textField.font = UIFont.systemFontOfSize(11.0)
        textField.textAlignment = NSTextAlignment.Center
        textField.height = 20
        textField.width = frame.width
        textField.userInteractionEnabled = false
        textField.text = clip.txt
        //        textField.center.y = clips![indexPath.row].y
        
        if (textField.text == "") {
            textField.hidden = true
        }
    }
}