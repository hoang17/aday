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
    
    func export(clip: Clip, friendName: String, profileImg: UIImage, completion: (savePathUrl: NSURL) -> Void) {
        
        print("processing video...")
        
        //  create new file to receive data
        let savePath = NSURL(fileURLWithPath: NSTemporaryDirectory() + "exp_" + clip.fname).absoluteString
        let savePathUrl = NSURL(string: savePath!)
        
        // Return if file existed
        let exfilePath = NSTemporaryDirectory() + "exp_" + clip.fname;
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(exfilePath) {
            print("file existed")
            completion(savePathUrl: savePathUrl!)
            return
            // try! fileManager.removeItemAtPath(exfilePath)
        }
        
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
        let size = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.width)
        
        let imglogo = UIImage(named: "pin")
        let logolayer = CALayer()
        logolayer.contents = imglogo?.CGImage
        logolayer.frame = CGRectMake(size.width - 105, 20, 45, 53)
        logolayer.opacity = 0.6

        let logotxtLayer = LCTextLayer()
        logotxtLayer.foregroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        logotxtLayer.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        logotxtLayer.string = "Pinly"
        logotxtLayer.fontSize = 22
        logotxtLayer.frame = CGRectMake(size.width-82, 12, 200, 56)
        
//        let url = NSURL(string: "https://graph.facebook.com/10154325476678184/picture?type=large&return_ssl_resources=1")
//        let data = NSData(contentsOfURL: url!)
//        let avaimg = UIImage(data: data!)
        //imglayer.contents = avaimg?.circle.CGImage

        let imglayer = CALayer()
        imglayer.contents = profileImg.circle.CGImage
        imglayer.frame = CGRectMake(15, size.height-60, 50, 50)
        
        let nameLayer = LCTextLayer()
        nameLayer.foregroundColor = UIColor.whiteColor().CGColor
        nameLayer.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        nameLayer.string = friendName
        nameLayer.fontSize = 22
        nameLayer.frame = CGRectMake(75, size.height-30, 300, 24)

        let locationLayer = LCTextLayer()
        locationLayer.foregroundColor = UIColor.whiteColor().CGColor
        locationLayer.font = UIFont(name: "OpenSans", size: 12.0)
        locationLayer.string = clip.subarea != "" ? clip.subarea + " · " + clip.city : clip.city + " · " + clip.country
        locationLayer.fontSize = 22
        locationLayer.frame = CGRectMake(75, size.height-55, 300, 24)
        
        let titleLayer = LCTextLayer()
        titleLayer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        titleLayer.string = clip.txt
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRectMake(0, size.height*(1-CGFloat(clip.y)), size.width, size.height/16.7)
        titleLayer.fontSize = size.height/35.5
        
        let videolayer = CALayer()
        let parentlayer = CALayer()
        
        videolayer.frame = CGRectMake((size.width-videoTrack.naturalSize.height)/2, 0, size.width, size.height)
        parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        parentlayer.addSublayer(videolayer)
        if clip.txt != "" {
            parentlayer.addSublayer(titleLayer)
        }
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
                completion(savePathUrl: savePathUrl!)
            case .Cancelled:
                print("cancelled \(exportSession.error)")
                dispatch_async(dispatch_get_main_queue()) {
                    completion(savePathUrl: savePathUrl!)
                }
            //case .Completed:
            default:
                print("export completed")
                dispatch_async(dispatch_get_main_queue()) {
                    completion(savePathUrl: savePathUrl!)
                }
            }
        })
        
    }
    
}
