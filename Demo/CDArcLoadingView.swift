//
//  CDArcLoadingView.swift
//  Demo
//
//  Created by 高炼 on 2017/7/3.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDArcLoadingView: UIView {
    var isAnimating = false {
        didSet {
            guard isAnimating != oldValue else { return }
            
            let animationKey = "8f9b3047aff0171161673cf288c8b662"
            
            if isAnimating {
                let ani = CABasicAnimation(keyPath: "progress")
                ani.duration = 1.5
                ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                ani.isRemovedOnCompletion = false
                ani.fromValue = 0
                ani.toValue = 1
                ani.repeatCount = Float.infinity
                layer.add(ani, forKey: animationKey)
            } else {
                layer.removeAnimation(forKey: animationKey)
            }
        }
    }

    var progress: CGFloat = 0 {
        didSet {
            guard let layer = layer as? CDArcLoadingLayer else { return }
            layer.progress = progress
        }
    }
    
    override static var layerClass: AnyClass {
        return CDArcLoadingLayer.self
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
        layer.contentsScale = UIScreen.main.scale
        
        isAnimating = true
    }
}

private class CDArcLoadingLayer: CALayer {
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var radius: CGFloat = 20 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override class func needsDisplay(forKey: String) -> Bool {
        switch forKey {
        case "progress":
            return true
        default:
            return super.needsDisplay(forKey: forKey)
        }
    }
    
    override init() {
        super.init()
        configure()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        guard let layer = layer as? CDArcLoadingLayer else { return }
        progress = layer.progress
        lineColor = layer.lineColor
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        ctx.translateBy(x: bounds.midX, y: bounds.midY)
        ctx.scaleBy(x: radius, y: radius)
        ctx.rotate(by: CGFloat.pi * 2 * progress)
        
        let fx = 1 - abs(progress - 0.5)
        let path = UIBezierPath(arcCenter: .zero, radius: 1, startAngle: 0, endAngle: -CGFloat.pi * fx, clockwise: false)
        
        path.lineWidth = 1/6.0
        
        lineColor.setStroke()
        
        path.stroke()
        
        ctx.saveGState()
        ctx.scaleBy(x: -1, y: -1)
        path.stroke()
        ctx.restoreGState()
    }
    
    //MARK: - Configure
    private func configure() {
        setNeedsDisplay()
    }
}


































