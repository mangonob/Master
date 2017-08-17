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
        
        let face = CIImage(contentsOf: Bundle.main.url(forResource: "square", withExtension: "png")!)!
        
        let context = CIContext()
        
        let gauss = CIFilter(name: "CIGaussianBlur")
        gauss?.setValue(face, forKey: kCIInputImageKey)
        gauss?.setValue(NSNumber(value: 10), forKey: kCIInputRadiusKey)
        
        let gradient1 = CIFilter(name: "CILinearGradient")
        gradient1?.setValue(CIVector(x: 0, y: 0.75 * face.extent.height), forKey: "inputPoint0")
        gradient1?.setValue(CIColor(color: .green), forKey: "inputColor0")
        gradient1?.setValue(CIVector(x: 0, y: 0.5 * face.extent.height), forKey: "inputPoint1")
        gradient1?.setValue(CIColor(color: UIColor.green.withAlphaComponent(0)), forKey: "inputColor1")
        
        let gradient2 = CIFilter(name: "CILinearGradient")
        gradient2?.setValue(CIVector(x: 0, y: 0.25 * face.extent.height), forKey: "inputPoint0")
        gradient2?.setValue(CIColor(color: .green), forKey: "inputColor0")
        gradient2?.setValue(CIVector(x: 0, y: 0.5 * face.extent.height), forKey: "inputPoint1")
        gradient2?.setValue(CIColor(color: UIColor.green.withAlphaComponent(0)), forKey: "inputColor1")
        
        let addition = CIFilter(name: "CIAdditionCompositing")
        addition?.setValue(gradient1?.outputImage, forKey: kCIInputImageKey)
        addition?.setValue(gradient2?.outputImage, forKey: "inputBackgroundImage")
        
        let blend = CIFilter(name: "CIBlendWithMask")
        blend?.setValue(gauss?.outputImage, forKey: kCIInputImageKey)
        blend?.setValue(addition?.outputImage, forKey: "inputMaskImage")
        blend?.setValue(face, forKey: "inputBackgroundImage")
        
        if let result = blend?.outputImage {
            if let cgImage = context.createCGImage(result, from: face.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
