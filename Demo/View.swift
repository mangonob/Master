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
        context.scaleBy(x: 1, y: -1)
        
        let cicontext = CIContext(cgContext: context, options: nil)
        let image = CIImage(contentsOf: Bundle.main.url(forResource: "image", withExtension: "jpg")!)!
        cicontext.draw(image, in: bounds, from: image.extent)
    }
}
