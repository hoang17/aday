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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class VideoHelper {
    
    static let sharedInstance = VideoHelper()
    
    // export clip with caption, profile, time & location
    func export(_ clip: Clip, friendName: String, profileImg: UIImage, completion: @escaping (_ savePathUrl: URL) -> Void) {
        
        print("processing video...")
        
        //  create new file to receive data
        let savePath = URL(fileURLWithPath: NSTemporaryDirectory() + "exp_" + clip.fname).absoluteString
        let savePathUrl = URL(string: savePath)
        
        // Check if file existed
        let exfilePath = NSTemporaryDirectory() + "exp_" + clip.fname
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: exfilePath) {
            print("file existed")
            completion(savePathUrl!)
            return
            //try! fileManager.removeItemAtPath(exfilePath)
        }
        
        let filePath = NSTemporaryDirectory() + clip.fname
        let inputURL = URL(fileURLWithPath: filePath)
        
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(url: inputURL, options: nil)
        
        // get video track
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        // let vid_duration = videoTrack.timeRange.duration
        let videoTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        try! compositionVideoTrack.insertTimeRange(videoTimerange, of: videoTrack, at: kCMTimeZero)
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // get audio track
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        // let audio_duration = audioTrack.timeRange.duration
        let audioTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        try! compositionAudioTrack.insertTimeRange(audioTimerange, of: audioTrack, at: kCMTimeZero)
        compositionAudioTrack.preferredTransform = audioTrack.preferredTransform
        
        // video size
        let size = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.width)
        
        // Pinly logo
        let imglogo = UIImage(named: "pin")
        let logolayer = CALayer()
        logolayer.contents = imglogo?.cgImage
        logolayer.frame = CGRect(x: size.width - 105, y: 20, width: 45, height: 53)
        logolayer.opacity = 0.6

        let logotxtLayer = LCTextLayer()
        logotxtLayer.foregroundColor = UIColor.white.withAlphaComponent(0.6).cgColor
        logotxtLayer.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        logotxtLayer.string = "Pinly"
        logotxtLayer.fontSize = 22
        logotxtLayer.frame = CGRect(x: size.width-82, y: 12, width: 200, height: 56)
        
//        let url = NSURL(string: "https://graph.facebook.com/10154325476678184/picture?type=large&return_ssl_resources=1")
//        let data = NSData(contentsOfURL: url!)
//        let avaimg = UIImage(data: data!)
        //imglayer.contents = avaimg?.circle.CGImage

        let imglayer = CALayer()
        imglayer.contents = profileImg.circle.cgImage
        imglayer.frame = CGRect(x: videoTrack.naturalSize.height - 65, y: size.height-60, width: 50, height: 50)
        
        let rwidth = size.width - videoTrack.naturalSize.height - 15
        
        let nameLayer = LCTextLayer()
        nameLayer.foregroundColor = UIColor.white.cgColor
        nameLayer.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        nameLayer.string = friendName
        nameLayer.fontSize = 22
        nameLayer.frame = CGRect(x: videoTrack.naturalSize.height + 15, y: size.height-35, width: rwidth, height: 26)
        nameLayer.isWrapped = true

        let date = Date(timeIntervalSince1970: clip.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM, yyyy"
        let dateString = formatter.string(from: date)

        let timeformatter = DateFormatter()
        timeformatter.timeStyle = .short
        var timeString = timeformatter.string(from: date)
        
        let dateLayer = LCTextLayer()
        dateLayer.foregroundColor = UIColor.white.cgColor
        dateLayer.font = UIFont(name: "OpenSans", size: 12.0)
        dateLayer.string = dateString
        dateLayer.fontSize = 20
        dateLayer.frame = CGRect(x: videoTrack.naturalSize.height + 15, y: size.height-75, width: rwidth, height: 30)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        let time = Float(dateFormatter.string(from: date))
        print("Check float value: \(time)")
        if time >= 18.00 || time <= 6.00 {
            timeString = "🌜 " + timeString
        }
        else {
            timeString = "🌞 " + timeString
        }
        
        let timeLayer = LCTextLayer()
        timeLayer.foregroundColor = UIColor.white.cgColor
        timeLayer.font = UIFont(name: "OpenSans-Bold", size: 12.0)
        timeLayer.string = timeString
        timeLayer.fontSize = 30
        timeLayer.frame = CGRect(x: videoTrack.naturalSize.height + 15, y: size.height-125, width: rwidth, height: 34)
        
        let locLayer1 = LCTextLayer()
        locLayer1.foregroundColor = UIColor.white.cgColor
        locLayer1.font = UIFont(name: "OpenSans", size: 12.0)
        locLayer1.string = "📍" + clip.lname
        locLayer1.fontSize = 22
        locLayer1.frame = CGRect(x: videoTrack.naturalSize.height + 15, y: size.height-200, width: rwidth, height: 80)
        locLayer1.isWrapped = true

        let locLayer2 = LCTextLayer()
        locLayer2.foregroundColor = UIColor.white.cgColor
        locLayer2.font = UIFont(name: "OpenSans", size: 12.0)
        locLayer2.string = clip.subarea + "\n" + clip.city + "\n" + clip.country
        locLayer2.fontSize = 20
        locLayer2.frame = CGRect(x: videoTrack.naturalSize.height + 15, y: size.height-355, width: rwidth-15, height: 200)
        locLayer2.isWrapped = true
        locLayer2.alignmentMode = "right"
        
        let titleLayer = LCTextLayer()
        titleLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        titleLayer.string = clip.txt
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRect(x: 0, y: size.height*(1-CGFloat(clip.y)), width: videoTrack.naturalSize.height, height: size.height/16.7)
        titleLayer.fontSize = size.height/35.5
        
        let videolayer = CALayer()
        let parentlayer = CALayer()
        
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentlayer.addSublayer(videolayer)
        if clip.txt != "" {
            parentlayer.addSublayer(titleLayer)
        }
        parentlayer.addSublayer(imglayer)
        parentlayer.addSublayer(nameLayer)
        parentlayer.addSublayer(dateLayer)
        parentlayer.addSublayer(timeLayer)
        parentlayer.addSublayer(locLayer1)
        parentlayer.addSublayer(locLayer2)
        parentlayer.addSublayer(logolayer)
        parentlayer.addSublayer(logotxtLayer)
        
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerinstruction.setTransform(compositionVideoTrack.preferredTransform, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        instruction.layerInstructions = [layerinstruction]
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        layercomposition.instructions = [instruction]
        
        // use AVAssetExportSession to export video
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = savePathUrl
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = layercomposition
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status{
            case  .failed:
                print("failed \(exportSession.error)")
                completion(savePathUrl!)
            case .cancelled:
                print("cancelled \(exportSession.error)")
                DispatchQueue.main.async {
                    completion(savePathUrl!)
                }
            //case .Completed:
            default:
                print("export completed")
                DispatchQueue.main.async {
                    completion(savePathUrl!)
                }
            }
        })
    }
    
    // export clip with caption
    func export(_ clip: Clip, completion: @escaping (_ savePathUrl: URL) -> Void) {
        print("processing video...")
        
        //  create new file to receive data
        let savePath = URL(fileURLWithPath: NSTemporaryDirectory() + "ex" + clip.fname).absoluteString
        let savePathUrl = URL(string: savePath)
        
        // Check if file existed
        let exfilePath = NSTemporaryDirectory() + "ex" + clip.fname
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: exfilePath) {
            //print("file existed")
            //completion(savePathUrl: savePathUrl!)
            //return
            try! fileManager.removeItem(atPath: exfilePath)
        }
        
        // input file
        let filePath = NSTemporaryDirectory() + clip.fname
        let inputURL = URL(fileURLWithPath: filePath)
        
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(url: inputURL, options: nil)
        
        // get video track
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        // let vid_duration = videoTrack.timeRange.duration
        let videoTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        try! compositionVideoTrack.insertTimeRange(videoTimerange, of: videoTrack, at: kCMTimeZero)
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // get audio track
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        // let audio_duration = audioTrack.timeRange.duration
        let audioTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        try! compositionAudioTrack.insertTimeRange(audioTimerange, of: audioTrack, at: kCMTimeZero)
        compositionAudioTrack.preferredTransform = audioTrack.preferredTransform
        
        // video size
        let size = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.width)
        
        let titleLayer = LCTextLayer()
        titleLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        titleLayer.string = clip.txt
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRect(x: 0, y: size.height*(1-CGFloat(clip.y)), width: videoTrack.naturalSize.height, height: size.height/16.7)
        titleLayer.fontSize = size.height/35.5
        
        let videolayer = CALayer()
        let parentlayer = CALayer()
        
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentlayer.addSublayer(videolayer)
        if clip.txt != "" {
            parentlayer.addSublayer(titleLayer)
        }
        
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerinstruction.setTransform(compositionVideoTrack.preferredTransform, at: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        instruction.layerInstructions = [layerinstruction]
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        layercomposition.instructions = [instruction]
        
        // use AVAssetExportSession to export video
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = savePathUrl
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = layercomposition
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status{
            case  .failed:
                print("failed \(exportSession.error)")
                completion(savePathUrl!)
            case .cancelled:
                print("cancelled \(exportSession.error)")
                DispatchQueue.main.async {
                    completion(savePathUrl!)
                }
            //case .Completed:
            default:
                print("export completed")
                DispatchQueue.main.async {
                    completion(savePathUrl!)
                }
            }
        })
    }
    
    // export clip
    func export(_ inputURL: URL, outputURL: URL, completion: @escaping () -> Void) {
        print("processing video...")
        
        // Check if file existed
        let exfilePath = outputURL.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: exfilePath) {
            //print("file existed")
            //completion(savePathUrl: savePathUrl!)
            //return
            try! fileManager.removeItem(atPath: exfilePath)
        }
        
        //        let filePath = NSTemporaryDirectory() + fileName
        //        let inputURL = NSURL(fileURLWithPath: filePath)
        
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(url: inputURL, options: nil)
        
        // get video track
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        // let vid_duration = videoTrack.timeRange.duration
        let videoTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        try! compositionVideoTrack.insertTimeRange(videoTimerange, of: videoTrack, at: kCMTimeZero)
        //compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // get audio track
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        // let audio_duration = audioTrack.timeRange.duration
        let audioTimerange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        try! compositionAudioTrack.insertTimeRange(audioTimerange, of: audioTrack, at: kCMTimeZero)
        compositionAudioTrack.preferredTransform = audioTrack.preferredTransform
        
        // video size
        let size = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
                
        let videolayer = CALayer()
        let parentlayer = CALayer()
        
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentlayer.addSublayer(videolayer)
        
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        //layerinstruction.setTransform(compositionVideoTrack.preferredTransform, atTime: kCMTimeZero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        instruction.layerInstructions = [layerinstruction]

        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        layercomposition.instructions = [instruction]
        
        // use AVAssetExportSession to export video
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = layercomposition
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status{
            case  .failed:
                print("failed \(exportSession.error)")
            case .cancelled:
                print("cancelled \(exportSession.error)")
            //case .Completed:
            default:
                print("export completed")
                DispatchQueue.main.async {
                    completion()
                }
            }
        })
    }
}
