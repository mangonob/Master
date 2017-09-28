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
    let item = CTBadgeBarButtonItem.init(image: #imageLiteral(resourceName: "message").withRenderingMode(.alwaysTemplate), cornerInset: .init(top: 0, left: 0, bottom: 0, right: 2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = item
        item.tintColor = UIColor.flatOrange

        view.backgroundColor = .white
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        item.setNumber((item.number ?? 0) + 1, animated: true)
    }
    
    @IBAction func longPressAction(_ sender: UILongPressGestureRecognizer) {
        item.setNumber(nil, animated: true)
    }
}

