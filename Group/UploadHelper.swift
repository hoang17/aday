//
//  UploadHelper.swift
//  Pinly
//
//  Created by Hoang Le on 10/12/16.
//  Copyright © 2016 ping. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AssetsLibrary
import ReachabilitySwift
import RealmSwift
import AVFoundation


class UploadHelper {
    
    static let sharedInstance = UploadHelper()
    
    var reachability: Reachability?
    var notificationToken: NotificationToken?
    var clipUploads: Results<ClipUpload>!
    let fileName = "output.mp4"
    let filePath: String!
    let fileUrl: NSURL!
    
    init() {
        filePath = NSTemporaryDirectory() + fileName
        fileUrl = NSURL(fileURLWithPath: filePath)
    }
    
    func start() {
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print(error)
        }
        
        clipUploads = AppDelegate.realm.objects(ClipUpload.self).filter("clipUploaded = false AND thumbUploaded = false")
        
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
            if let connected = snapshot.value as? Bool where connected {
                print("Connected")
                self.runUploadQueue()
            } else {
                print("Not connected")
            }
        })
    }
    
    func runUploadQueue() {
        for clipUpload in clipUploads {
            beginUpload(clipUpload)
        }
    }
    
    func enqueueUpload(clipUpload: ClipUpload) {
        
        let realm = AppDelegate.realm
        try! realm.write {
            realm.add(clipUpload, update: true)
        }
        if reachability == nil || reachability!.isReachable() {
            beginUpload(clipUpload)
        }
    }
    
    func beginUpload(clipUpload: ClipUpload) {
        
        if clipUpload.uploading == false {
            upload(clipUpload)
        }
        if clipUpload.uploadingThumb == false {
            uploadThumb(clipUpload)
        }
    }
    
    // Upload clip & thumb then save clip to db
    func upload(clipUpload: ClipUpload){
        
        clipUpload.uploading = true
        
        let uploadFile = clipUpload.fname
        let uploadFilePath = NSTemporaryDirectory() + uploadFile
        let uploadFileUrl = NSURL(fileURLWithPath: uploadFilePath)
        
        print("Uploading \(uploadFile)...")
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        gs.child("clips/" + uploadFile).putFile(uploadFileUrl, metadata: metadata) { metadata, error in
            
            // upload done
            if (error != nil) {
                print("upload clip error")
                print(error)
            } else {
                print("Clip uploaded to " + (metadata!.downloadURL()?.absoluteString)!)
                
                try! AppDelegate.realm.write {
                    clipUpload.clipUploaded = true
                }
            }
            
            clipUpload.uploading = false
        }
    }
    
    func uploadThumb(clipUpload: ClipUpload){
        
        clipUpload.uploadingThumb = true
        
        let uploadFile = clipUpload.fname
        let uploadFilePath = NSTemporaryDirectory() + uploadFile
        
        let thumbFilePath = NSTemporaryDirectory() + uploadFile + ".jpg"
        
        if !NSFileManager.defaultManager().fileExistsAtPath(thumbFilePath) {
            self.extractThumbImage(uploadFilePath, thumbFilePath: thumbFilePath)
        }
        
        // Upload thumb image
        let thumb = uploadFile + ".jpg"
        let thumbFileUrl = NSURL(fileURLWithPath: thumbFilePath)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com")
        
        gs.child("thumbs/" + thumb).putFile(thumbFileUrl, metadata: metadata) { metadata, error in
            
            // upload done
            if (error != nil) {
                print("upload thumb error")
                print(error)
            } else {
                print("Thumb uploaded to " + (metadata!.downloadURL()?.absoluteString)!)
                
                // Save clip to db
                
                let clip = Clip(clipUpload: clipUpload, thumb: (metadata!.downloadURL()?.absoluteString)!)

                // Create new clip at /users/$userid/clips/$clipid
                let update = [
                    "/users/\(clip.uid)/clips/\(clip.id)/": clip.toAnyObject(),
                    "/users/\(clip.uid)/uploaded":clip.date]
                
                let ref = FIRDatabase.database().reference()
                ref.updateChildValues(update)
                
                // Create new clip at /clips/$clipid
                ref.child("clips").child(clip.id).setValue(clip.toAnyObject())
                
                print("Clip is saved to db \(clip.id)")
                
                try! AppDelegate.realm.write {
                    clipUpload.thumbUploaded = true
                }
            }
            
            clipUpload.uploadingThumb = false
        }
    }
    
    // Extract thumb image from video
    func extractThumbImage(clipFilePath: String, thumbFilePath: String){
        do{
            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: clipFilePath), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            let uiimg = UIImage(CGImage: cgimg)
            let data = UIImageJPEGRepresentation(uiimg, 0.5)
            data!.writeToFile(thumbFilePath, atomically: true)
        } catch {
            print(error)
        }
    }
}
