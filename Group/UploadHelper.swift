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
import RealmSwift
import AVFoundation


class UploadHelper {
    
    static let sharedInstance = UploadHelper()
    
    var notificationToken: NotificationToken?
    var clipUploads: Results<ClipUpload>!
    let fileName = "output.mp4"
    let filePath: String!
    let fileUrl: NSURL!
    var connected = false
    
    init() {
        filePath = NSTemporaryDirectory() + fileName
        fileUrl = NSURL(fileURLWithPath: filePath)
    }
    
    func start() {
        clipUploads = AppDelegate.realm.objects(ClipUpload.self).filter("clipUploaded = false AND thumbUploaded = false")
        
        FIRDatabase.database().referenceWithPath(".info/connected").observeEventType(.Value, withBlock: { snapshot in
            self.connected = snapshot.value as? Bool ?? false
            if self.connected {
                print("Connected")
                self.runUploadQueue()
            } else {
                print("Disconnected")
            }
        })
    }
    
    func runUploadQueue() {
        
        if clipUploads.count > 0 {
            
            print("\(clipUploads.count) items in upload queue")
            
            for clipUpload in clipUploads {
                beginUpload(clipUpload)
            }
        } else {
            print("nothing in upload queue")
        }
    }
    
    func enqueueUpload(clipUpload: ClipUpload) {
        
        do {
            // rename video file
            let uploadFilePath = NSTemporaryDirectory() + clipUpload.fname
            let uploadFileUrl = NSURL(fileURLWithPath: uploadFilePath)
            try NSFileManager.defaultManager().moveItemAtURL(UploadHelper.sharedInstance.fileUrl, toURL: uploadFileUrl)
            
            // extract thumb image
            self.extractThumbImage(uploadFilePath)
            
            try AppDelegate.realm.write {
                AppDelegate.realm.add(clipUpload, update: true)
            }
            if connected {
                beginUpload(clipUpload)
            }
            
        } catch {
            print(error)
        }

    }
    
    func beginUpload(clipUpload: ClipUpload) {
        
        print("Begin upload")
        
        let uploadFilePath = NSTemporaryDirectory() + clipUpload.fname
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(uploadFilePath)) {
            print("Can not upload: File not found \(uploadFilePath)")
            try! AppDelegate.realm.write {
                AppDelegate.realm.delete(clipUpload)
            }
            return
        }
        
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
        
        let thumb = uploadFile + ".jpg"
        let thumbFilePath = uploadFilePath + ".jpg"
        let thumbFileUrl = NSURL(fileURLWithPath: thumbFilePath)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(thumbFilePath) {
            self.extractThumbImage(uploadFilePath)
        }
        
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
    func extractThumbImage(clipFilePath: String) {
        do{
            let thumbFilePath = clipFilePath + ".jpg"
            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: clipFilePath), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            let uiimg = UIImage(CGImage: cgimg)
            let data = UIImageJPEGRepresentation(uiimg, 0.5)
            data!.writeToFile(thumbFilePath, atomically: true)
        } catch {
            print("extract thumb error")
            print(error)
        }
    }
}
