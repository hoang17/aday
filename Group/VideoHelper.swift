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
    
    func export(clip: ClipModel) {
        
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
        
        //        let imglogo = UIImage(named: "globe")
        //        let imglayer = CALayer()
        //        imglayer.contents = imglogo?.CGImage
        //        imglayer.frame = CGRectMake(5, 5, 100, 100)
        //        imglayer.opacity = 0.6
        
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
        // parentlayer.addSublayer(imglayer)
        
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
        
//        // Delete file if existed
//        let filePath = NSTemporaryDirectory() + "exp_" + clip.fname;
//        let fileManager = NSFileManager.defaultManager()
//        if fileManager.fileExistsAtPath(filePath) {
//            try! fileManager.removeItemAtPath(filePath)
//        }
        
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
                
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    let library = ALAssetsLibrary()
//                    library.writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: { (assetURL:NSURL!, error:NSError?) -> Void in
//                        if error != nil {
//                            print(error)
//                            return
//                        }
//                        print(assetURL)
//                    })
//                    
//                })
            default:
                print("default")
            }
        })
        
    }
    
}
