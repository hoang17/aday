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
import Kingfisher
import CWStatusBarNotification

class UploadHelper {
    
    static let sharedInstance = UploadHelper()
    
    var notificationToken: NotificationToken?
    var clipUploads: Results<ClipUpload>!
    let fileName = "output.mp4"
    let filePath: String!
    let fileUrl: NSURL!
    var connected = false
    var uploading = [String:Bool]()
    var downloadTasks = [String: FIRStorageDownloadTask]()
    
    let ref = FIRDatabase.database().reference()
    
    init() {
        filePath = NSTemporaryDirectory() + fileName
        fileUrl = NSURL(fileURLWithPath: filePath)
    }
    
    func start() {
        clipUploads = AppDelegate.realm.objects(ClipUpload.self).filter("clipUploaded = false OR thumbUploaded = false")
        
        let online = ref.child("online/\(AppDelegate.uid)")
        let lastseen = ref.child("lastseen/\(AppDelegate.uid)")
        
        ref.child(".info/connected").observeEventType(.Value, withBlock: { snapshot in
            self.connected = snapshot.value as? Bool ?? false
            if self.connected {
                print("Connected")
                
                self.runUploadQueue()
                
                lastseen.onDisconnectSetValue(FIRServerValue.timestamp())
                lastseen.setValue(true)
                
                online.onDisconnectRemoveValue()
                online.setValue(["online": true, "name": AppDelegate.name])
                
            } else {
                print("Disconnected")
            }
        })
    }
    
    func runUploadQueue() {
        
        if clipUploads.count > 0 {
            
            print("\(clipUploads.count) items in upload queue")
            
            for clip in clipUploads {
                beginUpload(clip)
            }
        }
    }
    
    func enqueueUpload(clip: ClipModel) {
        
        do {
            // rename video file
            let uploadFilePath = NSTemporaryDirectory() + clip.fname
            let uploadFileUrl = NSURL(fileURLWithPath: uploadFilePath)
            try NSFileManager.defaultManager().moveItemAtURL(UploadHelper.sharedInstance.fileUrl, toURL: uploadFileUrl)
            
            // extract thumb image
            self.extractThumbImage(clip)
            
            clip.thumb = NSURL(fileURLWithPath: uploadFilePath + ".jpg").absoluteString!
            
            let user = AppDelegate.currentUser
            
            let clipUpload = ClipUpload(id: clip.id)
            
            let realm = AppDelegate.realm
            
            try realm.write {
                realm.add(clip, update: true)
                realm.add(clipUpload, update: true)
                user.uploaded = clip.date
            }
            if connected {
                beginUpload(clipUpload)
            } else {
                let notification = CWStatusBarNotification()
                notification.notificationLabelBackgroundColor = UIColor.redColor()
                notification.displayNotificationWithMessage("No network connection", forDuration: 2.0)
            }
            
        } catch {
            print(error)
        }

    }
    
    func beginUpload(clipUpload: ClipUpload) {
        
        if let clip = AppDelegate.realm.objectForPrimaryKey(ClipModel.self, key: clipUpload.id) {
         
            let uploadFilePath = NSTemporaryDirectory() + clip.fname
            
            // delete realm object if file not found
            if (!NSFileManager.defaultManager().fileExistsAtPath(uploadFilePath)) {
                print("Pin not uploaded, file not found \(uploadFilePath)")
                try! AppDelegate.realm.write {
                    AppDelegate.realm.delete(clip)
                }
                return
            }
            
            if uploading[clip.id] == true {
                print("Pin is uploading on another thread \(clip.id)")
                return
            }
            
            if clipUpload.clipUploaded && clipUpload.thumbUploaded {
                print("Pin is uploaded on another thread \(clip.id)")
            }
            
            print("Begin uploading pin \(clip.id)...")
            
            let group = dispatch_group_create()
            
            uploading[clip.id] = true
            
            if !clipUpload.clipUploaded {
                
                // enter upload clip
                dispatch_group_enter(group)
                
                upload(clip) { metadata, error in
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
                    // leave upload clip
                    dispatch_group_leave(group)
                }
            }
            
            if !clipUpload.thumbUploaded {
                
                // enter upload thumb
                dispatch_group_enter(group)
                
                uploadThumb(clip) { metadata, error in
                    // upload done
                    if (error != nil) {
                        print("upload thumb error")
                        print(error)
                    } else {
                        
                        let thumb = (metadata!.downloadURL()?.absoluteString)!
                        
                        print("Thumb uploaded to " + thumb)
                        
                        try! AppDelegate.realm.write {
                            clipUpload.thumb = thumb
                            clipUpload.thumbUploaded = true
                        }
                    }
                    // leave upload thumb
                    dispatch_group_leave(group)
                }
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                
                if !clipUpload.clipUploaded || !clipUpload.thumbUploaded {
                    
                    clipUpload.uploadRetry += 1
                    
                    if (clipUpload.uploadRetry > 3){
                        print("Can not upload pin after \(clipUpload.uploadRetry) retry")
                        try! AppDelegate.realm.write {
                            AppDelegate.realm.delete(clip)
                        }
                    }
                    return
                }
                
                let data = Clip(data: clip)
                data.thumb = clipUpload.thumb
                let uid = clip.uid
                
                // Create new pin at /pins/$userid/$pinid
                let update = [
                    "/pins/\(uid)/\(clip.id)": data.toAnyObject(),
                    "/users/\(uid)/uploaded": clip.date,
                    "/clips/\(clip.id)": data.toAnyObject()]
                
                self.ref.updateChildValues(update)
                
                print("Pin is saved to db \(clip.id)")
                
                self.uploading[clip.id] = false
                
                let notification = CWStatusBarNotification()
                notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
                notification.displayNotificationWithMessage("Pin uploaded", forDuration: 1.0)
            }
        } else {
            try! AppDelegate.realm.write {
                AppDelegate.realm.delete(clipUpload)
            }
        }
    }
    
    // Upload clip & thumb then save clip to db
    func upload(clip: ClipModel, completion: ((FIRStorageMetadata?, NSError?) -> Void)?){
        
        let uploadFile = clip.fname
        let uploadFilePath = NSTemporaryDirectory() + uploadFile
        let uploadFileUrl = NSURL(fileURLWithPath: uploadFilePath)
        
        print("Uploading \(uploadFile)...")
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        gs.child("clips/" + uploadFile).putFile(uploadFileUrl, metadata: metadata, completion: completion)
    }
    
    func uploadThumb(clip: ClipModel, completion: ((FIRStorageMetadata?, NSError?) -> Void)?){
        
        self.extractThumbImage(clip)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        let storage = FIRStorage.storage()
        let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com")
        
        let thumb = clip.fname + ".jpg"
        let thumbFileUrl = NSURL(fileURLWithPath: NSTemporaryDirectory() + thumb)
        
        gs.child("thumbs/" + thumb).putFile(thumbFileUrl, metadata: metadata, completion: completion)
    }
    
    // Extract thumb image from video
    func extractThumbImage(clip: ClipModel) {
        
        let clipFilePath = NSTemporaryDirectory() + clip.fname
        let thumbFilePath = clipFilePath + ".jpg"
        
        if NSFileManager.defaultManager().fileExistsAtPath(thumbFilePath) {
            return
        }
        
        do{
            let asset = AVURLAsset(URL: NSURL(fileURLWithPath: clipFilePath), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgimg = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            let uiimg = UIImage(CGImage: cgimg)
            let data = UIImageJPEGRepresentation(uiimg, 0.5)
            
            KingfisherManager.sharedManager.cache.storeImage(uiimg, originalData: data, forKey: clip.id)
            
            data!.writeToFile(thumbFilePath, atomically: true)
        } catch {
            print("extract thumb error")
            print(error)
        }
    }
    
    func downloadClip(fileName: String) -> FIRStorageDownloadTask? {
        // Check if file not existed then download
        let filePath = NSTemporaryDirectory() + fileName;
        
        //if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            
            if downloadTasks[fileName] == nil {
                print("Downloading file \(fileName)...")
                let storage = FIRStorage.storage()
                let gs = storage.referenceForURL("gs://aday-b6ecc.appspot.com/clips")
                let localURL = NSURL(fileURLWithPath: filePath)
                downloadTasks[fileName] = gs.child(fileName).writeToFile(localURL)
            }
            return downloadTasks[fileName]
        //}
        //return nil
    }
}
