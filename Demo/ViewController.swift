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
        
        let size = 64
        let length = size * size * size * 4
        var cube = [Float](repeating: 0, count: length)
        
        for b in 0..<size {
            for g in 0..<size {
                for r in 0..<size {
                    let red = Float(r) / Float(size - 1)
                    let green = Float(g) / Float(size - 1)
                    let blue = Float(b) / Float(size - 1)
                    
                    var h: CGFloat = 0
                
                    UIColor(red: CGFloat(red),
                            green: CGFloat(green),
                            blue: CGFloat(blue),
                            alpha: 1).getHue(&h, saturation: nil, brightness: nil, alpha: nil)
                    
                    h *= 360
                    
                    let step = (((b * size) + g) * size + r) * 4
                    let alpha: Float = (h > 100.0 && h < 140.0) ? 0.0 : 1.0
                    cube[step] = red * alpha
                    cube[step + 1] = green * alpha
                    cube[step + 2] = blue * alpha
                    cube[step + 3] = alpha
                }
            }
        }
        
        let data = NSData(bytes: UnsafeRawPointer(cube), length: length * MemoryLayout<Float>.size)
        
        let image = CIImage(contentsOf: Bundle.main.url(forResource: "green", withExtension: "png")!)!
        
        let filter = CIFilter(name: "CIColorCube")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: size), forKey: "inputCubeDimension")
        filter?.setValue(data, forKey: "inputCubeData")
        
        if let image = filter?.outputImage {
            imageView.image = UIImage(ciImage: image)
        }
    }
}
