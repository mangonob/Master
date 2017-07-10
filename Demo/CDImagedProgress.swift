//
//  CDImagedProgress.swift
//  Demo
//
//  Created by 高炼 on 2017/7/6.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDImagedProgress: UIControl {
    var value: Float {
        get {
            return Float(progress)
        }
        set {
            progress = CGFloat(newValue)
        }
    }
    
    var progress: CGFloat = 0.5 {
        didSet {
            sendActions(for: .valueChanged)
            setNeedsDisplay()
        }
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var originInImage: CGPoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var progressHeight: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var emptyTintColor: UIColor? {
        didSet {
            setNeedsDisplay()
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
        backgroundColor = .clear
        setNeedsDisplay()
        
        clipsToBounds = false
        layer.masksToBounds = false
    }
    
    //MARK: - Draw
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
       
        var margin: CGFloat = 0
        
        if let w = image?.size.width {
            margin = max(originInImage.x, w - originInImage.x)
        }
        margin = max(margin, progressHeight / 2)
        
        context.translateBy(x: margin, y: bounds.midY)
        
        let L = bounds.width - margin * 2
        
        var path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: L, y: 0))
        path.close()
        
        path.lineWidth = progressHeight
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        (emptyTintColor ?? tintColor.withAlphaComponent(0.2)).setStroke()
        path.stroke()
        
        path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: L * progress, y: 0))
        
        path.lineWidth = progressHeight
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        tintColor.setStroke()
        path.stroke()
        
        context.translateBy(x: L * progress - originInImage.x, y: 0 - originInImage.y)
        
        image?.draw(at: .zero)
    }
}




































