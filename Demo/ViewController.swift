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
        
        collectionView.collectionViewLayout = CMCarouselLayout()
        var transform = CATransform3DIdentity
        transform.m34 = -1/300.0
        transform = CATransform3DTranslate(transform, 0, 0, -44)
        collectionView.layer.sublayerTransform = transform
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        guard let layout = collectionView.collectionViewLayout as? CMCarouselLayout else { return }
        let translation = sender.translation(in: nil)
        
        struct Static {
            static var phase: CGFloat = 0
        }
        
        switch sender.state {
        case .began:
            Static.phase = layout.phase
        case .changed:
            layout.phase = Static.phase - translation.x / collectionView.bounds.width
        default:
            layout.fitPosition()
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let layout = collectionView.collectionViewLayout as? CMCarouselLayout {
            layout.setCurrentIndex(indexPath.row, direction: .clockwise)
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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

extension ViewController: CMCarouselLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: CMCarouselLayout, itemSizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, radiusOfLayout: CMCarouselLayout) -> CGFloat {
        return 44
    }
    
    func collectionView(_ collectionView: UICollectionView, initialPhaseOfLayout: CMCarouselLayout) -> CGFloat {
        return -CGFloat.pi / 180 * 80
    }
}
