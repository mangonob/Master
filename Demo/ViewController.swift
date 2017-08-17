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
        
        let family = CIImage(contentsOf: Bundle.main.url(forResource: "family", withExtension: "png")!)!
        
        let context = CIContext()
        
        let pixellate = CIFilter(name: "CIPixellate")
        pixellate?.setValue(family, forKey: kCIInputImageKey)
        pixellate?.setValue(10, forKey: "inputScale")
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: nil)
        
        let images = detector?.features(in: family).map { (feature) -> CIImage? in
            let filter = CIFilter(name: "CIRadialGradient")!
            let radius = max(feature.bounds.width, feature.bounds.height) / 2 * 1.2
            filter.setValue(NSNumber(value: Float(radius)), forKey: "inputRadius0")
            filter.setValue(NSNumber(value: Float(radius) - 10), forKey: "inputRadius1")
            filter.setValue(CIColor(color: .clear), forKey: "inputColor0")
            filter.setValue(CIColor(color: .green), forKey: "inputColor1")
            filter.setValue(CIVector(x: feature.bounds.midX, y: feature.bounds.midY), forKey: kCIInputCenterKey)
            return filter.outputImage
        }
        
        let combinedImage = images?.reduce(CIImage(), { (currentImage, nextImage) -> CIImage? in
            let filter = CIFilter(name: "CISourceOverCompositing")
            filter?.setValue(currentImage, forKey: "inputBackgroundImage")
            filter?.setValue(nextImage, forKey: kCIInputImageKey)
            return filter?.outputImage
        })
        
        let blend = CIFilter(name: "CIBlendWithMask")
        blend?.setValue(pixellate?.outputImage, forKey: kCIInputImageKey)
        blend?.setValue(combinedImage, forKey: "inputMaskImage")
        blend?.setValue(family, forKey: "inputBackgroundImage")
        
        if let result = blend?.outputImage {
            if let cgImage = context.createCGImage(result, from: family.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
