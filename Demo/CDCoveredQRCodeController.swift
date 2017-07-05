//
//  CDCoveredQRCodeController.swift
//  B2B-Seller
//
//  Created by 高炼 on 17/6/16.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit
import AVFoundation


class CDCoverView: UIView {
    //MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        backgroundColor = UIColor.clear
    }
    
    //MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        defer { context.restoreGState() }
        
    }
}

class CDCoveredQRCodeController: CDQRCodeController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func stringDidDetacted(_ string: String) {
        super.stringDidDetacted(string)
    }
}

