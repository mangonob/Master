//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.backgroundColor = UIColor.red.cgColor
    }
    
    var flag = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            if let layer = self?.view.layer {
                layer.transform = CATransform3DRotate(layer.transform, CGFloat.pi, 0, 0, 1)
            }
        }, completion: nil)
    }
}

