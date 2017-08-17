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
    
    let from = CIImage(contentsOf: Bundle.main.url(forResource: "from", withExtension: "png")!)!
    let to = CIImage(contentsOf: Bundle.main.url(forResource: "to", withExtension: "png")!)!
    
    var filter: CIFilter!
    var pixellate: CIFilter!
    
    lazy var context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = CIFilter(name: "CIDissolveTransition")!
        filter.setValue(from, forKey: kCIInputImageKey)
        filter.setValue(to, forKey: "inputTargetImage")
        
        pixellate = CIFilter(name: "CIPixellate")
        
        sliderAction(sender: nil)
    }
    
    @IBAction func sliderAction(sender: UISlider?) {
        let x = sender?.value ?? 0.0
        let y = 1 - 2 * abs(x - 0.5)
        
        filter.setValue(NSNumber(value: x), forKey: "inputTime")
        
        pixellate.setValue(filter.outputImage, forKey: kCIInputImageKey)
        pixellate.setValue(NSNumber(value: y * 90 + 0.1), forKey: "inputScale")
        
        if let ciImage = pixellate.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: .init(origin: .zero, size: .init(width: 391, height: 300))) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
