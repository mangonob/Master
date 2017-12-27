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
        transform.m34 = -1/500.0
        collectionView.layer.sublayerTransform = transform
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)
        if let layout = collectionView.collectionViewLayout as? Layout {
            layout.progress = min(max(location.x / collectionView.bounds.width, 0), 1)
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        let layout = Layout()
        layout.progress = 0.5
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}


extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.number = NSNumber(value: indexPath.row)
        cell.backgroundColor = UIColor.clear
        cell.contentView.layer.cornerRadius = 10
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 5
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
        return CGSize(width: 100, height: 100)
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
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        var attributes = [UICollectionViewLayoutAttributes]()
        
        let radius = (collectionView.delegate as? LayoutDelegate)?.collectionView?(collectionView, radiusOfLayout: self) ?? self.radius
        
        for section in 0..<collectionView.numberOfSections {
            let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
            
            var currentProgress = progress
            let progressStep = numberOfItems > 0 ? 1 / numberOfItems : 0
            
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                defer {
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
        }
        
        return attributes
    }
}


