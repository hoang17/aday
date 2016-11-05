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
import MapKit

class UploadHelper {
    
    static let sharedInstance = UploadHelper()
    
    var notificationToken: NotificationToken?
    var clipUploads: Results<ClipUpload>!
    let fileName = "output.mp4"
    let filePath: String!
    let fileUrl: URL!
    var connected = false
    var uploading = [String:Bool]()
    var downloadTasks = [String: FIRStorageDownloadTask]()
    
    let ref = FIRDatabase.database().reference()
    
    init() {
        filePath = NSTemporaryDirectory() + fileName
        fileUrl = URL(fileURLWithPath: filePath)
    }
    
    func start() {
        clipUploads = AppDelegate.realm.objects(ClipUpload.self).filter("clipUploaded = false OR thumbUploaded = false")
        
        let online = ref.child("online/\(AppDelegate.uid)")
        let lastseen = ref.child("lastseen/\(AppDelegate.uid)")
        
        ref.child(".info/connected").observe(.value, with: { snapshot in
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
    
    func enqueueUpload(_ clip: ClipModel, liloaded: Bool = true) {
        
        do {
            // rename video file
            let uploadFilePath = NSTemporaryDirectory() + clip.fname
            let uploadFileUrl = URL(fileURLWithPath: uploadFilePath)
            try FileManager.default.moveItem(at: UploadHelper.sharedInstance.fileUrl, to: uploadFileUrl)
            
            // extract thumb image
            self.extractThumbImage(clip)
            
            clip.thumb = URL(fileURLWithPath: uploadFilePath + ".jpg").absoluteString
            
            let user = AppDelegate.currentUser
            
            let clipUpload = ClipUpload(id: clip.id, liloaded: liloaded)
            
            let realm = AppDelegate.realm
            
            try realm?.write {
                realm?.add(clip, update: true)
                realm?.add(clipUpload, update: true)
                user?.uploaded = clip.date
            }
            if connected {
                beginUpload(clipUpload)
            } else {
                let notification = CWStatusBarNotification()
                notification.notificationLabelBackgroundColor = UIColor.red
                notification.display(withMessage: "No network connection", forDuration: 2.0)
            }
            
        } catch {
            print(error)
        }

    }
    
    func beginUpload(_ clipUpload: ClipUpload) {
        
        if let clip = AppDelegate.realm.object(ofType: ClipModel.self, forPrimaryKey: clipUpload.id) {
         
            let uploadFilePath = NSTemporaryDirectory() + clip.fname
            
            // delete realm object if file not found
            if (!FileManager.default.fileExists(atPath: uploadFilePath)) {
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
            
            let group = DispatchGroup()
            
            uploading[clip.id] = true
            
            var furl = ""
            
            if !clipUpload.clipUploaded {
                
                // enter upload clip
                group.enter()
                
                upload(clip) { metadata, error in
                    // upload done
                    if (error != nil) {
                        print("upload clip error")
                        print(error)
                    } else {
                        furl = metadata?.downloadURL()?.absoluteString ?? ""
                        print("Clip uploaded to " + furl)
                        
                        try! AppDelegate.realm.write {
                            clipUpload.clipUploaded = true
                        }
                    }
                    // leave upload clip
                    group.leave()
                }
            }
            
            if !clipUpload.thumbUploaded {
                
                // enter upload thumb
                group.enter()
                
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
                    group.leave()
                }
            }

            let info = LocationInfo()
            
            if !clipUpload.liloaded {

                // enter load location info group
                group.enter()

                let location = CLLocation(latitude: clip.lat, longitude: clip.long)
                info.load(location) { info in
                    
                    //print(clip.lname)
                    
                    // leave location thumb
                    group.leave()
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                
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
                
                try! AppDelegate.realm.write{
                    clip.furl = furl
                    if info.loaded {
                        clip.lname = info.name
                        clip.city = info.city
                        clip.country = info.country
                        clip.sublocal = info.sublocal
                        clip.subarea = info.subarea
                    }
                }
                
                let data = Clip(data: clip)
                data.thumb = clipUpload.thumb
                let uid = clip.uid
                
                // Create new pin at /pins/$userid/$pinid
                let update = [
                    "/pins/\(uid)/\(clip.id)": data.toAnyObject(),
                    "/users/\(uid)/uploaded": clip.date,
                    "/clips/\(clip.id)": data.toAnyObject()] as [String : Any]
                
                self.ref.updateChildValues(update)
                
                print("Pin is saved to db \(clip.id)")
                
                self.uploading[clip.id] = false
                
                let notification = CWStatusBarNotification()
                notification.notificationLabelBackgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
                notification.display(withMessage: "Pin uploaded", forDuration: 1.0)
            }
        } else {
            try! AppDelegate.realm.write {
                AppDelegate.realm.delete(clipUpload)
            }
        }
    }
    
    // Upload clip & thumb then save clip to db
    func upload(_ clip: ClipModel, completion: ((FIRStorageMetadata?, NSError?) -> Void)?){
        
        let uploadFile = clip.fname
        let uploadFilePath = NSTemporaryDirectory() + uploadFile!
        let uploadFileUrl = URL(fileURLWithPath: uploadFilePath)
        
        print("Uploading \(uploadFile)...")
        
        let storage = FIRStorage.storage()
        let gs = storage.reference(forURL: "gs://aday-b6ecc.appspot.com")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        gs.child("clips/" + uploadFile!).putFile(uploadFileUrl, metadata: metadata, completion: completion as! ((FIRStorageMetadata?, Error?) -> Void)?)
    }
    
    func uploadThumb(_ clip: ClipModel, completion: ((FIRStorageMetadata?, NSError?) -> Void)?){
        
        self.extractThumbImage(clip)
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        let storage = FIRStorage.storage()
        let gs = storage.reference(forURL: "gs://aday-b6ecc.appspot.com")
        
        let thumb = clip.fname + ".jpg"
        let thumbFileUrl = URL(fileURLWithPath: NSTemporaryDirectory() + thumb)
        
        gs.child("thumbs/" + thumb).putFile(thumbFileUrl, metadata: metadata, completion: completion as! ((FIRStorageMetadata?, Error?) -> Void)?)
    }
    
    // Extract thumb image from video
    func extractThumbImage(_ clip: ClipModel) {
        
        let clipFilePath = NSTemporaryDirectory() + clip.fname
        let thumbFilePath = clipFilePath + ".jpg"
        
        if FileManager.default.fileExists(atPath: thumbFilePath) {
            return
        }
        
        do{
            let asset = AVURLAsset(url: URL(fileURLWithPath: clipFilePath), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgimg = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiimg = UIImage(cgImage: cgimg)
            let data = UIImageJPEGRepresentation(uiimg, 0.5)
            
            KingfisherManager.shared.cache.removeImage(forKey: clip.id, processorIdentifier: uiimg, fromDisk: data)
            
            try? data!.write(to: URL(fileURLWithPath: thumbFilePath), options: [.atomic])
        } catch {
            print("extract thumb error")
            print(error)
        }
    }
    
    func downloadClip(_ fileName: String) -> FIRStorageDownloadTask? {
        let filePath = NSTemporaryDirectory() + fileName
        // Only download if file not existed
        if !FileManager.default.fileExists(atPath: filePath) {
            if downloadTasks[fileName] == nil {
                //print("Downloading file \(fileName)...")
                let storage = FIRStorage.storage()
                let gs = storage.reference(forURL: "gs://aday-b6ecc.appspot.com/clips")
                let localURL = URL(fileURLWithPath: filePath)
                downloadTasks[fileName] = gs.child(fileName).write(toFile: localURL)
            }
            return downloadTasks[fileName]
        }
        return nil
    }
}
