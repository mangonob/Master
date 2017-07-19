//
//  CLSliderPageController.swift
//  Demo
//
//  Created by 高炼 on 2017/7/19.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

struct CLSliderPageIndicatorAttribute {
    var frame: CGRect
    var color: UIColor
    var alpha: UIColor
    var transform: CGAffineTransform
}

@objc protocol CLSliderPageControllerDelegate {
}


@objc protocol CLSliderPageControllerDataSource {
    @objc optional func numberOfPages(in controller: CLSliderPageController) -> Int
    @objc optional func sliderPageController(_ controller: CLSliderPageController, titleForPage atIndex: Int) -> String?
    @objc optional func sliderPageController(_ controller: CLSliderPageController, viewController atIndex: Int) -> UIViewController?
    @objc optional func sliderPageController(_ controller: CLSliderPageController, sizeOfButton atIndex: Int, with recommendSize: CGSize) -> CGSize
    @objc optional func sliderPageController(_ controller: CLSliderPageController, attributeOfIndicator atIndex: Int, with recommendAttribute: CLSliderPageIndicatorAttribute) -> CLSliderPageIndicatorAttribute
}

class CLSliderPageController: UIViewController {
    private (set) lazy var topScrollView = UIScrollView()
    
    weak var delegate: CLSliderPageControllerDelegate?
    weak var dataSource: CLSliderPageControllerDataSource?
    
    private var _contentView: UIView!
    internal var contentView: UIView {
        get {
            UITableViewDataSource
            if _contentView == nil {
                _contentView = UIView()
                topScrollView.addSubview(_contentView)
            }
        }
    }
    
    internal var topContentSize: CGSize {
        didSet {
            contentView.frame = CGRect(origin: .zero, size: topContentSize)
            topScrollView.contentSize = topContentSize
        }
    }
    
    var titles: [String] {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
