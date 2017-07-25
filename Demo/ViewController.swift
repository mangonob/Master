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
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var imageSource = CGImageSourceCreateWithURL(Bundle.main.url(forResource: "images", withExtension: "gif")! as CFURL,
                                   [
                                    kCGImageSourceShouldCache as String: true,
                                    kCGImageSourceShouldAllowFloat as String: true,
                                    ] as CFDictionary)!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer(timeInterval: 0.1,
                      target: self,
                      selector: #selector(self.timerAction(sender:)),
                      userInfo: nil, repeats: true)
        
        timer.fire()
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    var currentIndex = 0
    
    func timerAction(sender: Timer) {
        let count = CGImageSourceGetCount(imageSource)
        
        guard let cgimage = CGImageSourceCreateImageAtIndex(imageSource, currentIndex, nil) else {
            timer.invalidate()
            timer = nil
            return
        }
        
    currentIndex = (currentIndex + 1) % count
        
        imageView.image = UIImage(cgImage: cgimage)
    }
}
