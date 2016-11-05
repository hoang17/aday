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
    var locationLabel = UILabel()
    var profileImg = UIImageView()
    var moreButton = UILabel()
    var clips: Results<ClipModel>!
    let cellWidth = 150
    let cellHeight = 266
    var index: Int = 0
    var friendName: String!
    var friendUid: String!
    
    var notificationToken: NotificationToken? = nil
    
    weak var controller: FriendsController?

    convenience init(friendUid: String) {
        self.init()
        
        self.friendUid = friendUid
        
        clips = AppDelegate.realm.objects(ClipModel.self).filter("uid = '\(friendUid)' AND trash = false AND date > \(AppDelegate.startdate)").sorted(byProperty: "date", ascending: false)
        
        self.notificationToken = clips.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard (self?.collectionView) != nil else { return }
            switch changes {
            case .initial:
                // self?.collectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    self?.collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    self?.collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }, completion: nil)
            case .error(let error):
                print(error)
            }
        }
        
        self.selectionStyle = .none
        
        moreButton.text = "..."
        moreButton.origin = CGPoint(x: UIScreen.main.bounds.width-40, y: 10)
        moreButton.size = CGSize(width: 40, height: 35)
        moreButton.textColor = UIColor.black
        moreButton.font = UIFont(name: "OpenSans-Bold", size: 20.0)
        moreButton.isUserInteractionEnabled = true
        
        profileImg.origin = CGPoint(x: 10, y: 13)
        profileImg.size = CGSize(width: 40, height: 40)
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.layer.masksToBounds = false
        profileImg.clipsToBounds = true
    
        nameLabel.origin = CGPoint(x: 60, y: 10)
        nameLabel.size = CGSize(width: self.width, height: 35)
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 13.0)
        
        locationLabel.origin = CGPoint(x: 60, y: 36)
        locationLabel.size = CGSize(width: self.width, height: 14)
        locationLabel.textColor = UIColor.gray
        locationLabel.font = UIFont(name: "OpenSans", size: 10.0)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 3
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.origin.y = 55
        collectionView.height = 290
        collectionView.width = UIScreen.main.bounds.width
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MiniViewCell.self, forCellWithReuseIdentifier: "MiniViewCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        self.addSubview(profileImg)
        self.addSubview(nameLabel)
        self.addSubview(moreButton)
        self.addSubview(locationLabel)
        self.addSubview(collectionView)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clips!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MiniViewCell", for: indexPath) as! MiniViewCell
        cell.subviews.forEach({ $0.removeFromSuperview() })
        
        let clip = clips![indexPath.row]
        let thumb = ClipThumbnail(clip: clip, frame: cell.bounds)
        cell.addSubview(thumb)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        play(indexPath.row)
    }
    
    func play(_ playIndex: Int) {
        
        let cameraPlayback = CameraPlaybackController(playIndex: playIndex, clips: clips)
        cameraPlayback.nameLabel.text = nameLabel.text
        if let atxt = cameraPlayback.nameLabel.attributedText?.mutableCopy() as? NSMutableAttributedString {
            cameraPlayback.nameLabel.width = atxt.size().width
        } else {
            cameraPlayback.nameLabel.width = 100
        }
        cameraPlayback.dateLabel.x = 50 + cameraPlayback.nameLabel.width
        cameraPlayback.profileImg.image = profileImg.image
        cameraPlayback.collectionView = self.collectionView
        cameraPlayback.friendName = self.friendName
        cameraPlayback.friendUid = self.friendUid

        let navigationController = UINavigationController(rootViewController: cameraPlayback)
        
        self.controller!.present(navigationController, animated: true, completion: nil)
    }
    
}
