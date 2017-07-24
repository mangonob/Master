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


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).first as? AVCaptureDevice else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        let session = AVCaptureSession()
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        session.addInput(input)
        
        let output = AVCaptureMovieFileOutput()
        
        
        session.addOutput(output)
        session.startRunning()
        
        output.startRecording(toOutputFileURL: URL(string: "file://\(NSHomeDirectory())/Documents/temp.mp4")!, recordingDelegate: self)
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Start")
    }
}
