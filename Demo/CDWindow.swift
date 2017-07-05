//
//  CDWindow.swift
//  Demo
//
//  Created by 高炼 on 17/6/13.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDWindow: UIWindow {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTest = super.hitTest(point, with: event)
        return hitTest == self ? nil : hitTest
    }
}


