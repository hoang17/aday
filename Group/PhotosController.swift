//
//  PhotosController.swift
//  Group
//
//  Created by Hoang Le on 9/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import MapKit
import Photos

class PhotosController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let manager = PHImageManager.defaultManager()
    var collectionView: UICollectionView!
    let cellWidth = 150
    let cellHeight = 266
    var players = [PlayerView]();

    var myGroup = dispatch_group_create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if #available(iOS 9.0, *) {
            allPhotosOptions.fetchLimit = 10
        } else {
            // Fallback on earlier versions
        }
        
        let result = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Video, options: allPhotosOptions)
        result.enumerateObjectsUsingBlock {
            
            let asset = $0.0 as? PHAsset
            
            let options = PHVideoRequestOptions()
            options.networkAccessAllowed = true
            
            dispatch_group_enter(self.myGroup)
            
            self.manager.requestPlayerItemForVideo(asset!, options: options, resultHandler: { (playerItem, _) -> Void in
                
                let player = PlayerView(playerItem: playerItem!, frame: CGRect(x: 0,y: 0,width: self.cellWidth, height: self.cellHeight))
                self.players.append(player)
//                self.playerItems.append(playerItem!);
                
                let option = PHImageRequestOptions()
                option.synchronous = true
                var thumbnail = UIImage()
                self.manager.requestImageForAsset(asset!, targetSize: CGSize(width: self.cellWidth, height: self.cellHeight), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    player.thumb = thumbnail
//                    self.thumbs.append(thumbnail)
                })
                
                dispatch_group_leave(self.myGroup)
                
            });
            
            dispatch_group_notify(self.myGroup, dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 3
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.height = 290
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        self.view.addSubview(collectionView)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        cell.subviews.forEach({ $0.removeFromSuperview() })
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = false
        cell.clipsToBounds = true
        
        let img = UIImageView(image: players[indexPath.row].thumb)
        img.frame = cell.bounds
        img.contentMode = UIViewContentMode.ScaleAspectFit
        cell.addSubview(img)
        
        let player = self.players[indexPath.row]
        cell.addSubview(player)
        cell.bringSubviewToFront(player)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let player = self.players[indexPath.row]
        player.play()
    }
    
}