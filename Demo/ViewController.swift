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
        
        let film = CIImage(contentsOf: Bundle.main.url(forResource: "film", withExtension: "png")!)!
        let context = CIContext()
        
        let sepiaTone = CIFilter(name: "CISepiaTone")
        sepiaTone?.setValue(film, forKey: kCIInputImageKey)
        sepiaTone?.setValue(NSNumber(value: 1.0), forKey: "inputIntensity")
        
        let randomGenerator = CIFilter(name: "CIRandomGenerator")
        
        let matrix = CIFilter(name: "CIColorMatrix")
        matrix?.setValue(randomGenerator?.outputImage, forKey: kCIInputImageKey)
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        matrix?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        let compositing = CIFilter(name: "CISourceOverCompositing")
        compositing?.setValue(sepiaTone?.outputImage, forKey: kCIInputImageKey)
        compositing?.setValue(matrix?.outputImage, forKey: "inputBackgroundImage")
        
        let transform = CIFilter(name: "CIAffineTransform")
        transform?.setValue(randomGenerator?.outputImage, forKey: kCIInputImageKey)
        transform?.setValue(NSValue(cgAffineTransform: CGAffineTransform(scaleX: 1.5, y: 25)), forKey: kCIInputTransformKey)
        
        let matrix2 = CIFilter(name: "CIColorMatrix")
        matrix2?.setValue(transform?.outputImage, forKey: kCIInputImageKey)
        matrix2?.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        matrix2?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        matrix2?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        matrix2?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        matrix2?.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        
        let dark = CIFilter(name: "CIMinimumComponent")
        dark?.setValue(matrix2?.outputImage, forKey: kCIInputImageKey)
        
        let multiply = CIFilter(name: "CIMultiplyCompositing")
        multiply?.setValue(dark?.outputImage, forKey: kCIInputImageKey)
        multiply?.setValue(compositing?.outputImage, forKey: "inputBackgroundImage")
        
        if let ciImage = multiply?.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: film.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
