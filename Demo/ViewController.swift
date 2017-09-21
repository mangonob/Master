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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.layer.mask = label.layer
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)
        let progress = min(max(location.x / view.bounds.width, 0), 1)
        progressView.setProgress(Float(progress), animated: true)
    }
}

