//
//  MyHazeFilter.swift
//  Demo
//
//  Created by Trinity on 2017/8/21.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreImage


private class MyHazeFilterFilterConstructor:NSObject, CIFilterConstructor {
    func filter(withName name: String) -> CIFilter? {
        return MyHazeFilter()
    }
}

class MyHazeFilter: CIFilter {
    var inputImage: CIImage?
    var inputColor: CIColor?
    var inputDistance: NSNumber?
    var inputSlope: NSNumber?
    
    private static var constructor = MyHazeFilterFilterConstructor()
    static var hazeRemovalKernel: CIKernel?
    
    override class func initialize() {
        super.initialize()
        registerName("MyHazeFilter", constructor: MyHazeFilter.constructor, classAttributes: [
            kCIAttributeDisplayName: "Haze Remover",
            kCIAttributeFilterCategories: [
                kCICategoryColorAdjustment, kCICategoryVideo,
                kCICategoryStillImage, kCICategoryInterlaced,
                kCICategoryNonSquarePixels
            ]
            ])
    }
    
    override var outputImage: CIImage? {
        if let inputImage = inputImage {
            let src = CISampler(image: inputImage)
            return MyHazeFilter.hazeRemovalKernel?.apply(withExtent: inputImage.extent,
                                                         roiCallback: { $1 },
                                                         arguments: [src, inputColor, inputDistance, inputSlope])
        }
        return nil
    }
    
    override var attributes: [String : Any] {
        var attributes = [String: [String: Any]]()

        attributes["inputDistance"] = [
            kCIAttributeMin: NSNumber(value: 0),
            kCIAttributeMax: NSNumber(value: 1),
            kCIAttributeSliderMin: NSNumber(value: 0),
            kCIAttributeSliderMax: NSNumber(value: 1),
            kCIAttributeDefault: NSNumber(value: 0.2),
            kCIAttributeIdentity: NSNumber(value: 0),
            kCIAttributeType: kCIAttributeTypeScalar,
        ]

        attributes["inputSlope"] = [
            kCIAttributeSliderMin: NSNumber(value: -0.01),
            kCIAttributeSliderMax: NSNumber(value: 0.01),
            kCIAttributeDefault: NSNumber(value: 0),
            kCIAttributeIdentity: NSNumber(value: 0),
            kCIAttributeType: kCIAttributeTypeScalar,
        ]
        
        attributes["inputColor"] = [
            kCIAttributeDefault: CIColor()
        ]
        
        return attributes
    }
    
    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        if MyHazeFilter.hazeRemovalKernel == nil {
            MyHazeFilter.hazeRemovalKernel = CIKernel(string: try! String(contentsOf:
                Bundle.main.url(forResource: "MyHazeRemoval", withExtension: "cikernel")!
                ))
        }
    }
}


