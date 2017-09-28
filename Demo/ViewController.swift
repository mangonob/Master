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
        
        let item = CDBandagedBarButtonItem.init(image: #imageLiteral(resourceName: "green.png"), cornerInset: .init(top: 0, left: 0, bottom: 0, right: 2))
        item.font = UIFont.systemFont(ofSize: 20)
        
        navigationItem.leftBarButtonItem = item

        view.backgroundColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let bandgeItem = navigationItem.leftBarButtonItem as? CDBandagedBarButtonItem  {
            bandgeItem.number = (bandgeItem.number ?? 0) + 1
        }
    }
}

