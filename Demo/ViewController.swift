//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreText
import MBProgressHUD
import ChameleonFramework

class Cell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    var number: NSNumber? {
        didSet {
            if let number = number {
                label.text = number.description
            }
        }
    }
}


class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = Layout()
        var transform = CATransform3DIdentity
        transform.m34 = -1/300.0
        transform = CATransform3DRotate(transform, CGFloat.pi / 180 * 6, -1, 0, 0)
        collectionView.layer.sublayerTransform = transform
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        guard let layout = collectionView.collectionViewLayout as? Layout else { return }
        let translation = sender.translation(in: nil)
        
        struct Static {
            static var progress: CGFloat = 0
        }
        
        switch sender.state {
        case .began:
            Static.progress = layout.progress
        case .changed:
            layout.progress = Static.progress - min(max(translation.x / collectionView.bounds.width, -1), 1)
        case .ended:
            print(sender.velocity(in: nil))
        default:
            break
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if let layout = collectionView.collectionViewLayout as? Layout {
            layout.setProgress(progress: 1, animated: true)
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let layout = collectionView.collectionViewLayout as? Layout {
            layout.setProgress(progress: CGFloat(indexPath.row) / 42, animated: true)
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.number = NSNumber(value: indexPath.row)
        cell.backgroundColor = UIColor.clear
        cell.contentView.layer.cornerRadius = 15
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 3
        cell.layer.shadowOffset = .zero
        cell.contentView.backgroundColor = UIColor.randomFlat
        return cell
    }
}

@objc protocol LayoutDelegate: UICollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: Layout, itemSizeAt indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, radiusOfLayout: Layout) -> CGFloat
}

extension ViewController: LayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: Layout, itemSizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, radiusOfLayout: Layout) -> CGFloat {
        return 150
    }
}

class Layout: UICollectionViewLayout {
    override var collectionViewContentSize: CGSize {
        return collectionView?.bounds.size ?? .zero
    }
    
    var itemSize: CGSize = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var radius: CGFloat = 100 {
        didSet {
            invalidateLayout()
        }
    }
    
    func setProgress(progress: CGFloat, animated: Bool) {
        setProgress(progress: progress, animated: animated, duration: 0.25)
    }
    
    fileprivate func setProgress(progress: CGFloat, animated: Bool, duration: CFTimeInterval) {
        if !animated {
            self.progress = progress
            return
        }
        
        class ProgressLayer: CALayer, CAAnimationDelegate {
            weak var layout: Layout?
            
            var progress: CGFloat = 0 {
                didSet {
                    layout?.progress = progress
                }
            }
            
            override class func needsDisplay(forKey: String) -> Bool {
                if forKey == "progress" {
                    return true
                }
                
                return super.needsDisplay(forKey: forKey)
            }
            
            override init(layer: Any) {
                super.init(layer: layer)
                guard let layer = layer as? ProgressLayer else { return }
                self.progress = layer.progress
                self.layout = layer.layout
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            init(layout: Layout) {
                super.init()
                self.layout = layout
            }
            
            func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
                removeFromSuperlayer()
            }
        }
        
        let progressLayer = ProgressLayer(layout: self)
        progressLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        collectionView?.layer.addSublayer(progressLayer)
        
        let ani = CABasicAnimation(keyPath: "progress")
        ani.fromValue = self.progress
        ani.toValue = progress
        ani.duration = duration
        ani.isRemovedOnCompletion = false
        ani.delegate = progressLayer
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        progressLayer.add(ani, forKey: nil)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        var result = [UICollectionViewLayoutAttributes]()
        
        let radius = (collectionView.delegate as? LayoutDelegate)?.collectionView?(collectionView, radiusOfLayout: self) ?? self.radius
        
        for section in 0..<collectionView.numberOfSections {
            var attributes = [UICollectionViewLayoutAttributes]()
            
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            
            guard numberOfItems > 0 else { continue }
            
            var currentProgress = -progress
            let progressStep = numberOfItems > 0 ? 1 / CGFloat(numberOfItems) : 0
            
            var progresses = [CGFloat](repeating: 0, count: numberOfItems)
            
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                defer {
                    progresses[row] = currentProgress
                    currentProgress += progressStep
                }
                
                let indexPath = IndexPath(row: row, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.center = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
                attribute.bounds = CGRect(origin: .zero, size: (collectionView.delegate as? LayoutDelegate)?.collectionView?(collectionView, layout: self, itemSizeAt: indexPath) ?? itemSize)
                
                var transform = CATransform3DIdentity
                transform = CATransform3DTranslate(transform, radius * sin(currentProgress * CGFloat.pi * 2), 0, radius * cos(currentProgress * CGFloat.pi * 2))
                
                attribute.transform3D = transform
                attribute.zIndex = -row
                
                attributes.append(attribute)
            }
            
            zip(progresses, attributes).sorted(by: { (left, right) -> Bool in
                return cos(left.0 * CGFloat.pi) < cos(right.0 * CGFloat.pi)
            }).map { $0.1 }.enumerated().forEach { $0.element.zIndex = -$0.offset }
            
            result.append(contentsOf: attributes)
        }
        
        return result
    }
}


