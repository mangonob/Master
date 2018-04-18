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
    var render: Render!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = view as? MTKView else {
            return
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = .clear
        
        render = Render(mtkView)
        
        mtkView.delegate = render
        
        render.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


