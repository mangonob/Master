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
        
        let count = CGImageSourceGetCount(imageSource)
        
        let path = "\(NSHomeDirectory())/Documents/temp.gif"
        print(path)
        let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL,
                                                           "com.compuserve.gif" as CFString,
                                                           count,
                                                           nil)!
        
        for i in 0..<count {
            CGImageDestinationAddImageFromSource(destination, imageSource, i, nil)
        }
        
        CGImageDestinationFinalize(destination)
    }
}
