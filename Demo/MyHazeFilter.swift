//
//  MyHazeFilter.swift
//  Demo
//
//  Created by Trinity on 2017/8/21.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class MyHazeFilter: CIFilter {
    var inputImage: CIImage?
    var inputColor: CIColor?
    var inputDistance: NSNumber?
    var inputSlope: NSNumber?
    
    static var hazeRemovalKernel: CIKernel?
    
    override class func initialize() {
        super.initialize()
    }
    
    override init() {
        if MyHazeFilter.hazeRemovalKernel == nil {
            MyHazeFilter.hazeRemovalKernel = CIKernel(string:
                "kernel vec4 myHazeRemovalKernel(sampler src,             // 1\n"
                "__color color,\n"
                "float distance,\n"
                "float slope)\n"
                "{\n"
                "vec4   t;\n"
                "float  d;\n"
                "\n"
                "d = destCoord().y * slope  +  distance;              // 2\n"
                "t = unpremultiply(sample(src, samplerCoord(src)));   // 3\n"
                "t = (t - d*color) / (1.0-d);                         // 4\n"
                "\n"
                "return premultiply(t);                               // 5\n"
                }
            )
        }
        super.init()
    }
}
