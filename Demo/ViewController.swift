//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import ImageIO
import MediaPlayer
import AVKit
import AssetsLibrary


class AVPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    override var layer: AVPlayerLayer {
        return super.layer as! AVPlayerLayer
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var imageProgress: CDImagedProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let asset = AVAsset(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
        
        let mutableComposition = AVMutableComposition()
        
        let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else { return }
        
        let allRange = CMTimeRange(start: kCMTimeZero, end: asset.duration)
        try? videoCompositionTrack.insertTimeRange(allRange, of: videoTrack, at: kCMTimeZero)
        
        let mutableVideoCompositoin = AVMutableVideoComposition()
        let instruction = AVMutableVideoCompositionInstruction()
        let layerInstruction = AVMutableVideoCompositionLayerInstruction()
        
        let endTransform = CGAffineTransform.identity.scaledBy(x: 0.49, y: 0.49)
        layerInstruction.setTransformRamp(fromStart: CGAffineTransform.identity, toEnd: endTransform, timeRange: allRange)
        
        instruction.timeRange = allRange
        instruction.layerInstructions = [layerInstruction]
        mutableVideoCompositoin.instructions = [instruction]
        
        let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = mutableVideoCompositoin.copy() as! AVVideoComposition
        exportSession?.outputFileType = AVFileTypeMPEG4
        let path = "\(NSHomeDirectory())/Documents/a.mp4"
        print(path)
        exportSession?.outputURL = URL(fileURLWithPath: path)
        exportSession?.exportAsynchronously(completionHandler: {
            print("Completion")
        })
    }
}














