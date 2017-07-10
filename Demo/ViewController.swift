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
        imageProgress.image = UIImage(named: "leaf")
        imageProgress.originInImage = CGPoint(x: 6, y: 16)
    }
    
    
    @IBAction func sliderAction(_ sender: UISlider) {
        imageProgress.value = sender.value
    }
}














