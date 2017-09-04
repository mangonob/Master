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
    lazy var animationView = LOTAnimationView(name: "loading_semicircle")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        animationView.frame = view.bounds
        
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
    }
}

