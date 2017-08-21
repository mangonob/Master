//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import SpriteKit
import Metal
import MetalKit
import ChameleonFramework


class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let haze = CIImage(contentsOf: Bundle.main.url(forResource: "haze", withExtension: "png")!)!
        let context = CIContext()
        
        MyHazeFilter.classForCoder()
        
        let filter = CIFilter(name: "MyHazeFilter") as! MyHazeFilter
        filter.inputSlope = 0
        filter.inputDistance = 0.2
        filter.inputColor = CIColor(red: 0, green: 0, blue: 1)
        filter.inputImage = haze
        
        if let ciImage = filter.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: haze.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
