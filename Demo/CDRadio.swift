//
//  CDRadio.swift
//  Demo
//
//  Created by 高炼 on 2017/7/3.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDRadio: UIControl {
    var radius: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
            sendActions(for: .valueChanged)
        }
    }
    
    override var tintColor: UIColor! {
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
    
    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //MARK: - Configure
    private func configure() {
        backgroundColor = .clear
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if bounds.contains(location) {
            isSelected = !isSelected
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.translateBy(x: bounds.midX, y: bounds.midY)
        context.scaleBy(x: radius, y: radius)
        
        let rect = CGRect(x: -1, y: -1, width: 2, height: 2)
        var path = UIBezierPath(ovalIn: rect)
        path.addClip()
        path.lineWidth = 1/12.0
        
        if isHighlighted {
            UIColor.black.withAlphaComponent(0.1).setFill()
            path.fill()
        }
        
        UIColor.black.withAlphaComponent(0.2).setStroke()
        path.stroke()
        
        path = UIBezierPath(ovalIn: rect.insetBy(dx: 1/4.0, dy: 1/4.0))
        if isSelected {
            tintColor.setFill()
            path.fill()
        }
    }
}
