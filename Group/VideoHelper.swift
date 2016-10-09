//
//  VideoHelper.swift
//  Pinly
//
//  Created by Hoang Le on 10/9/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVFoundation
import AVKit
import AssetsLibrary

class VideoHelper {
    
    static let sharedInstance = VideoHelper()
    
    func export(clip: ClipModel, friend: UserModel, profileImg: UIImage) {
        
        print("processing video...")
        
        let filePath = NSTemporaryDirectory() + clip.fname
        let inputURL = NSURL(fileURLWithPath: filePath)
        
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(URL: inputURL, options: nil)
        
        // get video track
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]
        // let vid_duration = videoTrack.timeRange.duration
        let videoTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        try! compositionVideoTrack.insertTimeRange(videoTimerange, ofTrack: videoTrack, atTime: kCMTimeZero)
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // get audio track
        let audioTrack = videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
        // let audio_duration = audioTrack.timeRange.duration
        let audioTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        try! compositionAudioTrack.insertTimeRange(audioTimerange, ofTrack: audioTrack, atTime: kCMTimeZero)
        compositionAudioTrack.preferredTransform = audioTrack.preferredTransform
        
        // video size
        let size = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width)
        
        let imglogo = UIImage(named: "pin")
        let logolayer = CALayer()
        logolayer.contents = imglogo?.CGImage
        logolayer.frame = CGRectMake(size.width - 65, 5, 27, 32)
        logolayer.opacity = 0.6

        let logotxtLayer = LCTextLayer()
        logotxtLayer.foregroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        logotxtLayer.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        logotxtLayer.string = "Pinly"
        logotxtLayer.fontSize = 14
        logotxtLayer.frame = CGRectMake(size.width-50, 3, 100, 28)
        
        let imglayer = CALayer()
        imglayer.contents = profileImg.circle.CGImage
        imglayer.frame = CGRectMake(15, size.height-40, 30, 30)
        
        let nameLayer = LCTextLayer()
        nameLayer.foregroundColor = UIColor.whiteColor().CGColor
        nameLayer.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        nameLayer.string = friend.name
        nameLayer.fontSize = 12
        nameLayer.frame = CGRectMake(55, size.height-30, 300, 28)

        let locationLayer = LCTextLayer()
        locationLayer.foregroundColor = UIColor.whiteColor().CGColor
        locationLayer.font = UIFont(name: "OpenSans", size: 12.0)
        locationLayer.string = clip.subarea != "" ? clip.subarea + " · " + clip.city : clip.city + " · " + clip.country
        locationLayer.fontSize = 12
        locationLayer.frame = CGRectMake(55, size.height-45, 300, 28)
        
        let titleLayer = LCTextLayer()
        titleLayer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        titleLayer.string = clip.txt
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRectMake(0, size.height*(1-CGFloat(clip.y)), size.width, size.height/16.7)
        titleLayer.fontSize = size.height/35.5
        
        let videolayer = CALayer()
        let parentlayer = CALayer()
        
        videolayer.frame = CGRectMake(0, 0, size.width, size.height)
        parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(titleLayer)
        parentlayer.addSublayer(imglayer)
        parentlayer.addSublayer(nameLayer)
        parentlayer.addSublayer(locationLayer)
        parentlayer.addSublayer(logolayer)
        parentlayer.addSublayer(logotxtLayer)
        
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerinstruction.setTransform(compositionVideoTrack.preferredTransform, atTime: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        instruction.layerInstructions = [layerinstruction]
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
        layercomposition.instructions = [instruction]
        
        //  create new file to receive data
        let savePath = NSURL(fileURLWithPath: NSTemporaryDirectory() + "exp_" + clip.fname).absoluteString
        
        // Delete file if existed
        let exfilePath = NSTemporaryDirectory() + "exp_" + clip.fname;
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(exfilePath) {
            print("file existed")
            return
//            try! fileManager.removeItemAtPath(exfilePath)
        }
        
        let savePathUrl = NSURL(string: savePath!)
        
        // use AVAssetExportSession to export video
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = savePathUrl
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = layercomposition
        exportSession.exportAsynchronouslyWithCompletionHandler({
            switch exportSession.status{
            case  .Failed:
                print("failed \(exportSession.error)")
            case .Cancelled:
                print("cancelled \(exportSession.error)")
            case .Completed:
                print("export completed")
                ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL, error) in
                    print(assetURL)
                    if error != nil {
                        print(error)
                    }
                })
            default:
                print("default")
            }
        })
        
    }
    
}
