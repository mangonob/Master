//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushToSlider() {
        let vc = CLSliderPageController()
        vc.delegate = self
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
        vc.titles = ["A", "AA", "A", "AA", "A"]
    }
}


extension ViewController: CLSliderPageControllerDelegate {
}

extension ViewController: CLSliderPageControllerDataSource {
    func numberOfPages(in controller: CLSliderPageController) -> Int {
        return 5
    }
    
    func sliderPageController(_ controller: CLSliderPageController, viewControllerAt index: Int) -> UIViewController? {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.randomFlat
        return vc
    }
}
