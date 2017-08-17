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
        
        let randomGenerator = CIFilter(name: "CIRandomGenerator")
        
        let matrix = CIFilter(name: "CIColorMatrix")
        matrix?.setValue(randomGenerator?.outputImage, forKey: kCIInputImageKey)
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        matrix?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        matrix?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        if let ciImage = matrix?.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: film.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
