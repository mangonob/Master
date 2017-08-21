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
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var slopeSlider: UISlider!
    
    lazy var filter = CIFilter(name: "MyHazeFilter") as! MyHazeFilter
    lazy var context = CIContext()
    lazy var haze = CIImage(contentsOf: Bundle.main.url(forResource: "haze", withExtension: "png")!)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyHazeFilter.classForCoder()
        
        filter.setValue(haze, forKey: kCIInputImageKey)
        filter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: kCIInputColorKey)
        
        updateImage()
    }
    
    func updateImage() {
        filter.setValue(slopeSlider.value, forKey: "inputSlope")
        filter.setValue(distanceSlider.value, forKey: "inputDistance")
        
        if let ciImage = filter.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: haze.extent) {
                imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        updateImage()
    }
}
