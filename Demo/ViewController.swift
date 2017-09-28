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
        
        let view1 = UIView(frame: view.bounds)
        let view2 = UIView(frame: view.bounds)
        view1.backgroundColor = UIColor.flatGreen
        view2.backgroundColor = UIColor.flatRed
        view1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(view1)
        view.addSubview(view2)
        
        let transition = CATransition()
        transition.startProgress = 0
        transition.endProgress = 1
        transition.type = kCATransitionPush
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.subtype = kCATransitionFromRight
        transition.duration = 2.5
        
        view1.layer.add(transition, forKey: nil)
        view2.layer.add(transition, forKey: nil)
        
        view1.isHidden = false
        view2.isHidden = true
    }
}

