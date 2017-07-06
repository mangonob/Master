//
//  AutoGrowUpTextView.swift
//  Demo
//
//  Created by 高炼 on 2017/7/5.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class AutoGrowUpTextView: UITextView {

    override var intrinsicContentSize: CGSize {
//        isScrollEnabled = contentSize.height > 200
        return CGSize(width: contentSize.width, height: min(contentSize.height, 200))
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
