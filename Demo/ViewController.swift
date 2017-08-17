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
        
        let face = CIImage(contentsOf: Bundle.main.url(forResource: "face", withExtension: "png")!)!
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: nil)
        
        var center: CIVector = CIVector(cgPoint: .zero)
        
        if let faceBounds = detector?.features(in: face).first?.bounds {
            center = CIVector(x: faceBounds.midX, y: faceBounds.midY)
            
            let filter = CIFilter(name: "CIRadialGradient")
            filter?.setValue(NSNumber(value: Double(max(face.extent.width, face.extent.height))), forKey: "inputRadius0")
            filter?.setValue(NSNumber(value: Double(max(faceBounds.width, faceBounds.height)) * 2), forKey: "inputRadius1")
            filter?.setValue(CIColor(color: .white), forKey: "inputColor0")
            filter?.setValue(CIColor(color: UIColor.white.withAlphaComponent(0)), forKey: "inputColor1")
            filter?.setValue(center, forKey: kCIInputCenterKey)
            
            let blend = CIFilter(name: "CISourceOverCompositing")
            blend?.setValue(filter?.outputImage, forKey: kCIInputImageKey)
            blend?.setValue(face, forKey: "inputBackgroundImage")
            
            let context = CIContext()
            if let cgImage = context.createCGImage(blend!.outputImage!, from: face.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
        
    }
}
