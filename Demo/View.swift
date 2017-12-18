//
//  View.swift
//  Demo
//
//  Created by 高炼 on 2017/12/15.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class View: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        UIBezierPath(roundedRect: bounds.insetBy(dx: 10, dy: 10), cornerRadius: 10).stroke()
    }
}
