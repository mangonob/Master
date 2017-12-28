//
//  CMCarouselLayout.swift
//  Demo
//
//  Created by 高炼 on 2017/12/28.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


@objc protocol CMCarouselLayoutDelegate: UICollectionViewDelegate {
    // Appearences customization
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CMCarouselLayout, itemSizeAt indexPath: IndexPath) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, radiusOfLayout: CMCarouselLayout) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, initialPhaseOfLayout: CMCarouselLayout) -> CGFloat
}


/**
 * Carousel layout of card, a subclass of UIColoectionViewLayout
 */
class CMCarouselLayout: UICollectionViewLayout {
    override var collectionViewContentSize: CGSize {
        return collectionView?.bounds.size ?? .zero
    }
    
    /**
     * size of card, default is zero
     * if you implement collectionView(_:layout:itemSizeAt:), it will use its return value
     */
    var itemSize: CGSize = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    /** the phase of carousel circle, default is 0. */
    var phase: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    /** scroll the card that at specified index to the position of initial phase */
    func setCurrentIndex(_ index: Int, direction: Direction = .auto) {
        guard let numberOfItems = collectionView?.numberOfItems(inSection: 0), numberOfItems > 0 else { return }
        setPhase(phase: CGFloat(index) / CGFloat(numberOfItems), animated: true, direction: direction)
    }
    
    /**
     * radius of carousel circle, default is 100.
     * If you implement collectionView(_:radiusOfLayout:), it will use its return value
     */
    var radius: CGFloat = 100 {
        didSet {
            invalidateLayout()
        }
    }
    
    /** fit the position of card to align initial phase */
    func fitPosition() {
        guard let numberOfItems = collectionView?.numberOfItems(inSection: 0), numberOfItems > 0 else { return }
        setCurrentIndex(Int(floor(CGFloat(numberOfItems) * phase + 0.5)))
    }
    
    /**
     * the rotate direction when set phase
     */
    enum Direction: UInt {
        case clockwise, counterClockwise, auto, unspecific
    }
    
    func setPhase(phase: CGFloat, animated: Bool, duration: CFTimeInterval = 0.25, direction: Direction = .unspecific) {
        if !animated {
            self.phase = phase
            return
        }
        
        class PahseLayer: CALayer, CAAnimationDelegate {
            weak var layout: CMCarouselLayout?
            
            var phase: CGFloat = 0 {
                didSet {
                    layout?.phase = phase
                }
            }
            
            override class func needsDisplay(forKey: String) -> Bool {
                if forKey == "phase" {
                    return true
                }
                
                return super.needsDisplay(forKey: forKey)
            }
            
            override init(layer: Any) {
                super.init(layer: layer)
                guard let layer = layer as? PahseLayer else { return }
                self.phase = layer.phase
                self.layout = layer.layout
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            init(layout: CMCarouselLayout) {
                super.init()
                self.layout = layout
            }
            
            func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
                removeFromSuperlayer()
                if let end = (anim as? CABasicAnimation)?.toValue as? CGFloat {
                    self.layout?.phase = end
                }
            }
        }
        
        let phaseLayer = PahseLayer(layout: self)
        phaseLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        collectionView?.layer.addSublayer(phaseLayer)
        
        func near(_ value: CGFloat, by: CGFloat = 0.5) -> CGFloat {
            return modf(modf(value - by - 0.5).1 + 1).1 + by - 0.5
        }
        
        let nearFrom = near(self.phase)
        let autoTo = near(phase, by: nearFrom)
        
        let ani = CABasicAnimation(keyPath: "phase")
        ani.fromValue = nearFrom
        ani.toValue = autoTo
        
        switch direction {
        case .unspecific:
            ani.fromValue = self.phase
            ani.toValue = phase
        case .auto:
            break
        case .clockwise:
            if autoTo < nearFrom {
                ani.toValue = autoTo + 1
            }
        case .counterClockwise:
            if autoTo > nearFrom {
                ani.toValue = autoTo - 1
            }
        }
        
        ani.duration = duration
        ani.isRemovedOnCompletion = false
        ani.delegate = phaseLayer
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        phaseLayer.add(ani, forKey: nil)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        var result = [UICollectionViewLayoutAttributes]()
        
        let radius = (collectionView.delegate as? CMCarouselLayoutDelegate)?.collectionView?(collectionView, radiusOfLayout: self) ?? self.radius
        
        for section in 0..<collectionView.numberOfSections {
            var attributes = [UICollectionViewLayoutAttributes]()
            
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            
            guard numberOfItems > 0 else { continue }
            
            var currentPahse = -phase + ((collectionView.delegate as? CMCarouselLayoutDelegate)?.collectionView?(collectionView, initialPhaseOfLayout: self) ?? 0) / (CGFloat.pi * 2)
            let phaseStep = numberOfItems > 0 ? 1 / CGFloat(numberOfItems) : 0
            
            var phasees = [CGFloat](repeating: 0, count: numberOfItems)
            
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                defer {
                    phasees[row] = currentPahse
                    currentPahse += phaseStep
                }
                
                let indexPath = IndexPath(row: row, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.center = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
                attribute.bounds = CGRect(origin: .zero, size: (collectionView.delegate as? CMCarouselLayoutDelegate)?.collectionView?(collectionView, layout: self, itemSizeAt: indexPath) ?? itemSize)
                
                var transform = CATransform3DIdentity
                transform = CATransform3DTranslate(transform, radius * sin(currentPahse * CGFloat.pi * 2), 0, radius * cos(currentPahse * CGFloat.pi * 2))
                
                attribute.transform3D = transform
                
                attributes.append(attribute)
            }
            
            zip(phasees, attributes).sorted(by: { (left, right) -> Bool in
                return cos(left.0 * CGFloat.pi * 2) < cos(right.0 * CGFloat.pi * 2)
            }).map { $0.1 }.enumerated().forEach { $0.element.zIndex = $0.offset }
            
            result.append(contentsOf: attributes)
        }
        
        return result
    }
}


