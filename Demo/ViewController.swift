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
    fileprivate var metrics = [Dim2Metrics](repeating: Dim2Metrics(width: .percentage(1), height: .length(5)), count: 1024 * 4)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var layout1 = Layout1()
    lazy var layout2 = Layout2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.setCollectionViewLayout(layout2, animated: true)
    }
    
    private var isBegin = false
    private var is2 = true
    
    @IBAction func sender(_ sender: UISwitch) {
        collectionView.setCollectionViewLayout(sender.isOn ? layout2 : layout1, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform.identity.rotated(by: CGFloat(arc4random()) / CGFloat(UInt32.max) * 4 * CGFloat.pi - 2 * CGFloat.pi).scaledBy(x: 0.0001, y: 0.0001)
        UIView.animate(withDuration: 1, delay: 0, options: [.allowUserInteraction], animations: {
            cell.transform = CGAffineTransform.identity
        }, completion: nil)
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

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metrics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.randomFlat
        return cell
    }
}

class Layout1: UICollectionViewFlowLayout {
    override var minimumLineSpacing: CGFloat {
        get {
            return 0
        }
        set {
        }
    }
    
    override var minimumInteritemSpacing: CGFloat {
        get {
            return 0
        }
        set {
        }
    }
    
    override var itemSize: CGSize {
        get {
            return CGSize(width: 40, height: 40)
        }
        set {
            super.itemSize = newValue
        }
    }
}


class Layout2: UICollectionViewFlowLayout {
    override var minimumLineSpacing: CGFloat {
        get {
            return 0
        }
        set {
        }
    }
    
    override var minimumInteritemSpacing: CGFloat {
        get {
            return 0
        }
        set {
        }
    }
    
    override var itemSize: CGSize {
        get {
            return CGSize(width: 70, height: 70)
        }
        set {
            super.itemSize = newValue
        }
    }
}


//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return metrics[indexPath.row].calculate(collectionView.bounds.size)
//    }
//}
















