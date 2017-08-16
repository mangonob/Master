//
//  View.swift
//  Demo
//
//  Created by 高炼 on 2017/6/22.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

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
        
        detector?.features(in: image).forEach({ (feature) in
            let path = UIBezierPath(rect: feature.bounds)
            path.lineWidth = 4
            UIColor.green.setStroke()
            path.stroke()
        })
    }
}
