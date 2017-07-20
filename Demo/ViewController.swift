//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import ImageIO
import MediaPlayer
import AVKit
import AssetsLibrary


class AVPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    override var layer: AVPlayerLayer {
        return super.layer as! AVPlayerLayer
    }
}

class ViewController: UIViewController {
    @IBAction func pushAction(_ sender: Any) {
        let vc = CLSliderPageController()
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
}


extension ViewController: CLSliderPageControllerDataSource {
    func numberOfPages(in controller: CLSliderPageController) -> Int {
        return 3
    }
    
    func sliderPageController(_ controller: CLSliderPageController, viewControllerAt index: Int) -> UIViewController? {
        let vc = UIViewController()
        vc.view.backgroundColor = [UIColor.red, UIColor.blue, UIColor.green][index]
        return vc
    }
    
    func sliderPageController(_ controller: CLSliderPageController, titleForPageAt index: Int, highlight: Bool) -> String? {
        return ["A", "B", "CCCCCCCC"][index]
    }
}


struct Dim2Metrics {
    enum Metrics: CustomStringConvertible {
        case zero
        
        case length(CGFloat)
        case percentage(CGFloat)
        indirect case add(Metrics, Metrics)
        indirect case sub(Metrics, Metrics)
        indirect case mul(Metrics, CGFloat)
        indirect case div(Metrics, CGFloat)
        
        static func +(a: Metrics, b: Metrics) -> Metrics {
            return .add(a, b)
        }
        
        static func -(a: Metrics, b: Metrics) -> Metrics {
            return .sub(a, b)
        }
        
        static func *(a: Metrics, b: CGFloat) -> Metrics {
            return .mul(a, b)
        }
        
        static func /(a: Metrics, b: CGFloat) -> Metrics {
            return .div(a, b)
        }
        
        var description: String {
            switch self {
            case .zero:
                return "0"
            case .length(let len):
                return len.description
            case .percentage(let per):
                return "\(per * 100)%"
            case .add(let a, let b):
                return "(\(a) + \(b))"
            case .sub(let a, let b):
                return "(\(a) - \(b))"
            case .mul(let a, let b):
                return "\(a) * \(b)"
            case .div(let a, let b):
                return "\(a) / \(b)"
            }
        }
        
        func calculate(_ withValue: CGFloat) -> CGFloat {
            switch self {
            case .zero:
                return 0
            case .length(let a):
                return a
            case .percentage(let a):
                return a * withValue
            case .add(let a, let b):
                return a.calculate(withValue) + b.calculate(withValue)
            case .sub(let a, let b):
                return a.calculate(withValue) - b.calculate(withValue)
            case .mul(let a, let b):
                return a.calculate(withValue) * b
            case .div(let a, let b):
                return a.calculate(withValue) / b
            }
        }
    }
    
    var width: Metrics = .zero
    var height: Metrics = .zero
    
    func calculate(_ withSize: CGSize) -> CGSize {
        return CGSize(width: width.calculate(withSize.width), height: height.calculate(withSize.height))
    }
}

typealias Dim1Metrics = Dim2Metrics.Metrics












