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

func RGBToHSV(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
    var hsv: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
    
    let mx = max(r, max(g, b))
    let mi = min(r, min(g, b))
    let factor = (mx - mi) * 60
    
    hsv.2 = mx
    hsv.1 = min(max((mx - mi) / mx, 0), 1)
    
    
    if r == mx {
        hsv.0 = (g - b) / factor
    } else if g == mx {
        hsv.0 = 120 + (b - r) / factor
    } else if b == mx {
        hsv.0 = 240 + (r - g) / factor
    }
    
    hsv.0 = min(max(hsv.0, 0), 360)
    
    return hsv
}

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = 64
        let length = size * size * size * 4
        var cube = [CGFloat](repeating: 0, count: length)
        
        for b in 0..<size {
            for g in 0..<size {
                for r in 0..<size {
                    let red = CGFloat(r) / CGFloat(size - 1)
                    let green = CGFloat(g) / CGFloat(size - 1)
                    let blue = CGFloat(b) / CGFloat(size - 1)
                    
                    let h = RGBToHSV(red, green, blue).0
                    let step = (((b * size) + g) * size + r)
                    let alpha: CGFloat = (h > 100.0 && h < 140.0) ? 0.0 : 1.0
                    cube[step] = red * alpha
                    cube[step + 1] = green * alpha
                    cube[step + 2] = blue * alpha
                    cube[step + 3] = alpha
                }
            }
        }
        
        let data = NSData(bytes: UnsafeRawPointer(cube), length: length)
        
        let image = CIImage(contentsOf: Bundle.main.url(forResource: "green", withExtension: "png")!)!
        
        let filter = CIFilter(name: "CIColorCube")
        filter?.setValue(image, forKey: "inputImage")
        filter?.setValue(NSNumber(value: size), forKey: "inputCubeDimension")
        filter?.setValue(data, forKey: "inputCubeData")
        
        if let image = filter?.outputImage {
            imageView.image = UIImage(ciImage: image)
        }
    }
}
