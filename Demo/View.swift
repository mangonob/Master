//
//  View.swift
//  Demo
//
//  Created by 高炼 on 2017/12/18.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class Layer: CALayer {
    var progress: CGFloat = 0
    var startValue: Int = 0
    var endValue: Int = 42
    var number: NSNumber?
    var font: UIFont = UIFont.systemFont(ofSize: 24)
    var textColor: UIColor = UIColor.black
    var horizontalHeightRate: CGFloat = 1.0
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        guard let layer = layer as? Layer else { return }
        
        self.classForCoder.storagePropertyNames.forEach { self.setValue(layer.value(forKey: $0), forKey: $0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplay(forKey: String) -> Bool {
        if storagePropertyNames.contains(forKey) {
            return true
        }
        
        return super.needsDisplay(forKey: forKey)
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        
        let current = startValue + Int(progress * CGFloat(endValue - startValue))
        
        let attributes: [String: Any] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        ]
        
        let currentAttributedString = NSAttributedString(string: current.description, attributes: attributes)
        let nextAttributedString = NSAttributedString(string: (current + 1).description, attributes: attributes)
        
        var maxSize = CGSize(width: max(currentAttributedString.size().width, nextAttributedString.size().width),
                             height: max(currentAttributedString.size().height, nextAttributedString.size().height))
        maxSize.height *= horizontalHeightRate
        
        let rect = CGRect(x: bounds.midX - maxSize.width / 2, y: bounds.midY - maxSize.height / 2, width: maxSize.width, height: maxSize.height)
        UIBezierPath(rect: rect).addClip()
        
        var stepProgress = progress * CGFloat(endValue - startValue)
        stepProgress = stepProgress - floor(stepProgress)
        
        let currentPoint = CGPoint(x: bounds.midX - currentAttributedString.size().width / 2, y: bounds.midY - stepProgress * maxSize.height - currentAttributedString.size().height / 2)
        let nextPoint = CGPoint(x: bounds.midX - nextAttributedString.size().width / 2, y: bounds.midY + (1 - stepProgress) * maxSize.height - nextAttributedString.size().height / 2)
        
        currentAttributedString.draw(at: currentPoint)
        nextAttributedString.draw(at: nextPoint)
    }
}

class View: UIView {
    override var layer: Layer {
        get {
            return super.layer as! Layer
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        setNeedsDisplay()
//
//        layer.setNeedsDisplay()
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override static var layerClass: AnyClass {
        return Layer.classForCoder()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}


extension NSObject {
    static var storagePropertyNames: [String] {
        var count: UInt32 = 0
        let propertyList = class_copyPropertyList(self, &count)
        let properties = Array(UnsafeBufferPointer(start: propertyList, count: Int(count))).flatMap { (property) -> String? in
            guard let property = property else { return nil }
            guard let name = String(utf8String: property_getName(property)) else { return nil }
            guard let attributes = String(utf8String: property_getAttributes(property)) else { return nil }
            guard let last = attributes.components(separatedBy: ",").last else { return nil }
            return last.starts(with: "V") ? name : nil
        }
        
        return properties
    }
}
