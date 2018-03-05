//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 2017/12/29.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let device = MTLCreateSystemDefaultDevice(),
            let queue = device.makeCommandQueue(),
            let commandBuffer = queue.makeCommandBuffer() {
            let library = device.makeDefaultLibrary()
            let fun = library?.makeFunction(name: "func")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

