//
//  View.swift
//  Demo
//
//  Created by 高炼 on 2017/6/22.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import OpenAL


extension CGRect {
    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(origin: .zero, size: CGSize(width: width, height: height))
        origin = CGPoint(x: center.x - width / 2, y: center.y - height / 2)
    }
}

class View: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        
        let cicontext = CIContext(cgContext: context, options: nil)
        let image = CIImage(contentsOf: Bundle.main.url(forResource: "image", withExtension: "jpg")!)!
        
        context.scaleBy(x: bounds.width / image.extent.width, y: -bounds.height / image.extent.height)
        
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: cicontext, options: [ CIDetectorAccuracy: CIDetectorAccuracyHigh ])
        
        cicontext.draw(image, in: image.extent, from: image.extent)
        
        CIFilter.filterNames(inCategories: nil).forEach { print(CIFilter(name: $0)!.attributes) }
        
        detector?.features(in: image).forEach({ (feature) in
            guard let faceFeature = feature as? CIFaceFeature else { return }
            UIColor.green.setStroke()
            context.setLineWidth(4)
            context.stroke(faceFeature.bounds)
            context.stroke(CGRect(center: faceFeature.leftEyePosition, width: 10, height: 10))
            context.stroke(CGRect(center: faceFeature.rightEyePosition, width: 10, height: 10))
            context.stroke(CGRect(center: faceFeature.mouthPosition, width: 10, height: 10))
        })
    }
}
