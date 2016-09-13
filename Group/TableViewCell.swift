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
import RealmSwift

class TableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    var nameLabel = UILabel()
    var profileImg = UIImageView()
    var clips: [Clip]!
    var friend: User!
    let cellWidth = 150
    let cellHeight = 266
//    var player: MiniPlayer!
    var index: Int = 0
    
    weak var controller: UIViewController?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None;
        
        profileImg.origin = CGPoint(x: 10, y: 15)
        profileImg.size = CGSize(width: 40, height: 40)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
    
        nameLabel.origin = CGPoint(x: 60, y: 15)
        nameLabel.size = CGSize(width: self.width, height: 35)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 13.0)
//        nameLabel.font = UIFont(name: "SourceSansPro-Bold", size: 13.0)
//        nameLabel.font = UIFont.boldSystemFontOfSize(13)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 3
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.origin.y = 55
        collectionView.height = 290
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(MiniViewCell.self, forCellWithReuseIdentifier: "MiniViewCell")
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MiniViewCell", forIndexPath: indexPath) as! MiniViewCell
        cell.subviews.forEach({ $0.removeFromSuperview() })
        
        let clip = clips![indexPath.row]
        let mp = MiniPlayer(clip: clip, frame: cell.bounds)
        
        cell.addSubview(mp.img)
        cell.addSubview(mp.textField)
        cell.addSubview(mp.dateLabel)
//        cell.index = indexPath.row
//        cell.tableCell = self
        
        return cell
    }
    
//    func playerDidFinishPlaying(){
//        player.player.seekToTime(kCMTimeZero)
//        NSNotificationCenter.defaultCenter().removeObserver(self,
//                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                            object:player.player.currentItem)
//        if index+1 < clips.count {
//            index += 1
//            collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
//            let clip = clips![index]
//            player = MiniPlayer(clip: clip, frame: CGRect(x: 0,y: 0,width: cellWidth, height: cellHeight))
//            player.play()
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
//                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                             object: player.player.currentItem)
//        }
//    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        play(indexPath.row)
    }
    
    func play(playIndex: Int) {
        
        let cameraPlayback = CameraPlaybackController()
        
//        for clip in self.clips {
//            let player = ClipPlayer(clip: clip)
//            cameraPlayback.players.append(player)
//        }
        
        cameraPlayback.clips = self.clips
        
        cameraPlayback.player = cameraPlayback.playerAtIndex(playIndex)
        cameraPlayback.playerAtIndex(playIndex+1)
        cameraPlayback.playerAtIndex(playIndex-1)
        
        cameraPlayback.playIndex = playIndex
        cameraPlayback.nameLabel.text = nameLabel.text
        let atxt = cameraPlayback.nameLabel.attributedText!.mutableCopy() as! NSMutableAttributedString
        cameraPlayback.nameLabel.width = atxt.size().width
        cameraPlayback.dateLabel.x = 50 + cameraPlayback.nameLabel.width
        cameraPlayback.profileImg.image = profileImg.image
        cameraPlayback.collectionView = self.collectionView
        cameraPlayback.friend = friend
        
        self.controller!.presentViewController(cameraPlayback, animated: true, completion: nil)
    }
    
//    func playMini(playIndex: Int){
//        
//        if index != playIndex || player == nil {
//            if player != nil {
//                player.pause()
//                NSNotificationCenter.defaultCenter().removeObserver(self,
//                                                                    name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                                    object:player.player.currentItem)
//            }
//            
//            index = playIndex
//            let clip = clips![index]
//            player = MiniPlayer(clip: clip, frame: CGRect(x: 0,y: 0,width: cellWidth, height: cellHeight))
//            player.play()
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
//                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                             object: player.player.currentItem)
//            
//        }
//        else {
//            if player.playing() {
//                player.pause()
//                NSNotificationCenter.defaultCenter().removeObserver(self,
//                                                                    name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                                    object:player.player.currentItem)
//            }
//            else{
//                player.play()
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying),
//                                                                 name: AVPlayerItemDidPlayToEndTimeNotification,
//                                                                 object: player.player.currentItem)
//                
//            }
//            
//        }
//    
//        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
//    }
    
}
