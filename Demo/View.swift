//
//  View.swift
//  Demo
//
//  Created by 高炼 on 2017/6/22.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class View: UIView {
    override var frame: CGRect {
        get {
            return CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        set {
            super.frame = CGRect(x: 0, y: 0, width: 100, height: 100) 
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
