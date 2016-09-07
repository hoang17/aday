//
//  PreviewController.swift
//  Group
//
//  Created by Hoang Le on 9/7/16.
//  Copyright © 2016 ping. All rights reserved.
//

import AVKit
import AVFoundation


class CameraPreviewController: AVPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = NSURL(fileURLWithPath: outputPath)
        let asset = AVAsset(URL: outputFileURL)
        self.showsPlaybackControls = false
        self.player = AVPlayer(playerItem: AVPlayerItem(asset:asset))
        self.player?.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraPreviewController.playerDidFinishPlaying(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: player!.currentItem)
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        self.dismissViewControllerAnimated(true) { 
            //
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

