//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = CIContext()
        
        let filter = CIFilter(name: "CISepiaTone")!                         // 2
        filter.setValue(0.8, forKey: kCIInputIntensityKey)
        let image = CIImage(contentsOf: Bundle.main.url(forResource: "image", withExtension: "jpg")!)
        filter.setValue(image, forKey: kCIInputImageKey)
        let result = filter.outputImage!                                    // 4
        
        if let cgImage = context.createCGImage(result, from: result.extent) {
            imageView.image = UIImage(cgImage: cgImage)
        }
    }
}
