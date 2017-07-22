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
    @IBOutlet var switcher: UISwitch!
    
    @IBAction func action(sender: UISwitch) {
        isTorchOn = !isTorchOn
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        
        isTorchOn = !isTorchOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var isTorchOn: Bool = false {
        didSet {
            if let device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).first as? AVCaptureDevice {
                try? device.lockForConfiguration()
                device.torchMode = isTorchOn ? .on : .off
                device.unlockForConfiguration()
                
                switcher.setOn(isTorchOn, animated: true)
            }
        }
    }
}
