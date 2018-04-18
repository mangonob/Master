//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 2017/12/29.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import Metal
import simd
import MetalKit
import ModelIO

class ViewController: UIViewController {
    @IBOutlet var segmentSlider: UISlider!
    @IBOutlet var mtkView: MTKView!
    
    var render: Render!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = .black
        
        render = Render(mtkView)
        
        mtkView.delegate = render
        
        render.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
        sliderAction(segmentSlider)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        Render.segmentFactor = UInt32(sender.value)
    }
}


