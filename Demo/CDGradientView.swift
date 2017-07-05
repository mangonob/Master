//
//  CDGradientView.swift
//  B2B-Seller
//
//  Created by 高炼 on 2017/6/19.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit

class CDGradientView: UIView {
    var colors = [UIColor]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var locations = [CGFloat]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var startPoint: CGPoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var colorComponents: UnsafePointer<CGFloat>! {
        let components = colors.flatMap { (color) -> [CGFloat] in
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: nil)
            return [r, g, b, 1]
        }
        return  UnsafePointer(components)
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
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.scaleBy(x: bounds.width, y: bounds.height)
        
        let components = colors.flatMap { (color) -> [CGFloat] in
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: nil)
            return [r, g, b, 1]
        }
        
        if let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(),
                                     colorComponents: components,
                                     locations: locations,
                                     count: min(colors.count, locations.count)) {
            context.drawLinearGradient(gradient,
                                       start: startPoint,
                                       end: endPoint,
                                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        
        NSAttributedString(string: "mangonob").draw(at: .zero)
    }
}
