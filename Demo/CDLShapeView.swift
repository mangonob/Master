//
//  CDLShapeView.swift
//  B2B-Seller
//
//  Created by 高炼 on 17/6/7.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit

@objc protocol CDLShapeViewDelegate {
    @objc optional func lShapeViewChangeIndex(shapeView: CDLShapeView, index: Int)
}

class CDLShapeView: UIView {
    enum Style {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
        
        var value: (CGFloat, CGFloat) {
            switch self {
            case .leftTop:
                return (1, 1)
            case .leftBottom:
                return (1, -1)
            case .rightTop:
                return (-1, 1)
            case .rightBottom:
                return (-1, -1)
            }
        }
    }
    
    weak var delegate: CDLShapeViewDelegate?
    
    var edgeSize: CGSize = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var selectedIndexChangedHandler: ((Int) -> Void)?
    var titles = [String]() {
        didSet {
            if titles.count == 0 {
                selectedIndex = NSNotFound
            } else if selectedIndex >= 0 && selectedIndex < titles.count{
            } else {
                selectedIndex = titles.count - 1
            }
            
            setNeedsDisplay()
        }
    }
    
    var selectedIndex: Int = NSNotFound {
        didSet {
            setNeedsDisplay()
            selectedIndexChangedHandler?(selectedIndex)
            delegate?.lShapeViewChangeIndex?(shapeView: self, index: selectedIndex)
        }
    }
    
    var cornerRadius: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var focusTitleColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var disfocusTitleColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var focusTitleFont: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var disfocusTitleFont: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var style: Style = .rightTop {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        UIGraphicsPushContext(context)
        defer { UIGraphicsPopContext() }
        context.saveGState()
        defer { context.restoreGState() }
        
        // Stroke Border
        tintColor.setStroke()
        rectInfos.path.addClip()
        
        subviews.filter { $0.restorationIdentifier == "\(self)" }.forEach { $0.removeFromSuperview() }
        
        for i in 0..<titles.count {
            context.saveGState()
            defer { context.restoreGState() }
            
            let container = rectAtIndex(i)
            if i != selectedIndex {
                let path = UIBezierPath(rect: container)
                path.lineWidth = borderWidth * 2
                path.stroke()
                path.fill(with: .clear, alpha: 0)
            }
            
            let focusFont = focusTitleFont ?? UIFont.systemFont(ofSize: 16)
            let disfocusFont = disfocusTitleFont ?? UIFont.systemFont(ofSize: 16)
            let font = i == selectedIndex ? focusFont : disfocusFont
            
            let label = UILabel()
            label.restorationIdentifier = "\(self)"
            label.frame = container.insetBy(dx: 8, dy: 8)
            label.text = titles[i]
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = false
            label.font = font
            label.textAlignment = .center
            label.textColor = i == selectedIndex ? (focusTitleColor ?? tintColor): (disfocusTitleColor ?? UIColor.darkGray)
            addSubview(label)
        }
        
        let path = rectInfos.path
        path.lineWidth = borderWidth * 2
        path.stroke()
    }
    
    //MARK: - Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for i in 0..<titles.count {
            if rectAtIndex(i).contains(location) {
                selectedIndex = i
                break
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return rectInfos.path.contains(point)
    }
    
    //MARK: - Utitlies
    internal var rectInfos: (tags: CGRect, body: CGRect, path: UIBezierPath) {
        var horzontal: CGRectEdge = .maxXEdge
        var vertical: CGRectEdge = .minYEdge
        
        switch style {
        case .rightTop:
            horzontal = .minXEdge
        case .leftBottom:
            vertical = .maxYEdge
        case .rightBottom:
            horzontal = .minXEdge
            vertical = .maxYEdge
        default: break
        }
        
        var slices = bounds.divided(atDistance: edgeSize.height, from: vertical)
        
        let tags = slices.slice.divided(atDistance: bounds.width - edgeSize.width, from: horzontal).slice
        let body = slices.remainder
        
        slices = bounds.divided(atDistance: edgeSize.height, from: .minYEdge)
        let originalTags = slices.slice.divided(atDistance: bounds.width - edgeSize.width, from: .maxXEdge).slice
        let originalBody = slices.remainder
        
        
        let path = UIBezierPath()
        
        let A = CGPoint(x: originalTags.minX, y: originalTags.maxY)
        let B = CGPoint(x: originalTags.minX, y: originalTags.minY)
        let C = CGPoint(x: originalTags.maxX, y: originalTags.minY)
        let D = CGPoint(x: originalBody.maxX, y: originalBody.maxY)
        let E = CGPoint(x: originalBody.minX, y: originalBody.maxY)
        let F = CGPoint(x: originalBody.minX, y: originalBody.minY)
        
        let R = cornerRadius
        let B0 = CGPoint(x: B.x + R, y: B.y + R)
        let C0 = CGPoint(x: C.x - R, y: C.y + R)
        let D0 = CGPoint(x: D.x - R, y: D.y - R)
        let E0 = CGPoint(x: E.x + R, y: E.y - R)
        let F0 = CGPoint(x: F.x + R, y: F.y + R)
        
        let B1 = CGPoint(x: B.x, y: B0.y)
        let C1 = CGPoint(x: C0.x, y: C.y)
        let D1 = CGPoint(x: D.x, y: D0.y)
        let E1 = CGPoint(x: E0.x, y: E.y)
        let F1 = CGPoint(x: F.x, y: F0.y)
        
        var current: CGFloat = CGFloat(M_PI)
        
        func next() -> CGFloat {
            current += CGFloat(M_PI_2)
            return current
        }
        
        path.move(to: A)
        
        zip([B1, C1, D1, E1, F1], [B0, C0, D0, E0, F0]).forEach { (to, center) in
            path.addLine(to: to)
            path.addArc(withCenter: center, radius: R, startAngle: current, endAngle: next(), clockwise: true)
        }
        
        path.addLine(to: A)
        path.close()
        
        var transform = CGAffineTransform(translationX: (1 - style.value.0) / 2 * bounds.width,
                                          y: (1 - style.value.1) / 2 * bounds.height)
        transform = transform.scaledBy(x: style.value.0, y: style.value.1)
        
        path.apply(transform)
        
        return (tags: tags, body: body, path: path)
    }
    
    internal func rectAtIndex(_ index: Int) -> CGRect {
        guard titles.count > 0 && index >= 0 && index < titles.count else  { return.zero }
        
        var result = rectInfos.tags
        
        let width = result.width / CGFloat(titles.count)
        
        for i in 1..<titles.count {
            result = result.divided(atDistance: width, from: i <= index ? .minXEdge : .maxXEdge).remainder
        }
        
        return result
    }
}

















































