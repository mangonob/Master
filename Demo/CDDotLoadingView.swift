//
//  CDDotLoadingView.swift
//  B2B-Seller
//
//  Created by 高炼 on 17/5/18.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit


enum CDLoadingViewStyle: UInt {
    case line, circle
}

class CDDotLoadingView: UIView {
    override static var layerClass: AnyClass {
        return CAReplicatorLayer.classForCoder()
    }
    
    override var layer: CAReplicatorLayer {
        return super.layer as! CAReplicatorLayer
    }
    
    private var dotlayer: CALayer {
        get {
            if let dot = layer.sublayers?.first {
                return dot
            } else {
                layer.addSublayer(CALayer())
                return self.dotlayer    // avoid recursive
            }
        }
    }
    
    @IBInspectable
    var hidesWhenStopped: Bool = true {
        didSet {
            updateLoading()
        }
    }
    
    var isLoading = true {
        didSet {
            updateLoading()
        }
    }
    
    @IBInspectable
    var duration: CFTimeInterval = 1.5 {
        didSet {
            updateLoading()
        }
    }
    
    @IBInspectable
    var radius: CGFloat = 5 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    var length: CGFloat = 24 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    var dotCount: Int = 3 {
        didSet {
            layoutSubviews()
            updateLoading()
        }
    }
    
    @IBInspectable
    var dotColor: UIColor = .blue {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    var minAlpha: CGFloat = 0.2 {
        didSet {
            updateLoading()
        }
    }
    
    @IBInspectable
    var maxAlpha: CGFloat = 1 {
        didSet {
            updateLoading()
        }
    }
    
    @IBInspectable
    var minScale: CGFloat = 0.8 {
        didSet {
            updateLoading()
        }
    }
    
    @IBInspectable
    var maxScale: CGFloat = 1 {
        didSet {
            updateLoading()
        }
    }
    
    var contentImage: UIImage? {
        didSet {
            layoutSubviews()
        }
    }
    
    var style: CDLoadingViewStyle = .line {
        didSet {
            layoutSubviews()
        }
    }
    
    //MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        dotColor = UIColor.blue
        dotlayer.isHidden = false
        layoutSubviews()
        updateLoading()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dotlayer.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        
        if let image = contentImage?.cgImage {
            dotlayer.contents = image
            dotlayer.cornerRadius = 0
            dotlayer.backgroundColor = UIColor.clear.cgColor
        } else {
            dotlayer.cornerRadius = radius
            dotlayer.backgroundColor = dotColor.cgColor
        }
        
        var p = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        p.x -= length / 2
        dotlayer.position = p
        
        layer.instanceCount = dotCount
        
        var transform: CATransform3D!
        
        switch style {
        case .line:
            transform = dotCount > 1 ? CATransform3DMakeTranslation(length / CGFloat(dotCount - 1), 0, 0) : CATransform3DIdentity
        case .circle:
            transform = CATransform3DMakeRotation(CGFloat(M_PI * 2) / CGFloat(dotCount), 0, 0, 1)
        }
        
        layer.instanceTransform = transform
    }
    
    //MARK: - Update
    private func updateLoading() {
        isHidden = hidesWhenStopped && !isLoading
        
        dotlayer.removeAllAnimations()
        
        guard isLoading else { return }
        
        let group = CAAnimationGroup()
        
        let ani = CABasicAnimation(keyPath: "opacity")
        ani.fromValue = maxAlpha
        ani.toValue = minAlpha
        
        let ani2 = CABasicAnimation(keyPath: "transform.scale")
        ani2.fromValue = maxScale
        ani2.toValue = minScale
        
        group.animations = [ani, ani2]
        
        group.beginTime = CACurrentMediaTime() - duration
        group.repeatCount = Float.infinity
        group.duration = duration / 2
        group.autoreverses = true
        group.isRemovedOnCompletion = false
        
        dotlayer.add(group, forKey: nil)
        
        layer.instanceDelay = dotCount > 1 ? duration / CFTimeInterval(dotCount) : 0
    }
}

