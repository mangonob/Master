//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreText


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.contentMode = .center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let layer = view.layer as? Layer else { return }
        
        layer.removeAllAnimations()
        
        let ani = CABasicAnimation(keyPath: "progress")
        ani.fromValue = 0
        ani.toValue = 1
        ani.duration = 0.25 * 42
        layer.progress = 1
        layer.add(ani, forKey: nil)
    }
}
