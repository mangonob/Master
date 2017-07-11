//
//  CDCircledCrossControl.swift
//  Demo
//
//  Created by 高炼 on 2017/7/11.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

private let kCDCircledCrossRaito: CGFloat = 0.8

private class CDCircledCrossLayer: CALayer {
    var lineWidth: CGFloat = 4
    
    var lineColor: UIColor = .blue
    
    var centerLineFactor: CGFloat = sqrt(3) / 3
    
    var radius: CGFloat = 20
    
    var progress: CGFloat = 0
    
    var theta: CGFloat {
        return asin(min(max( (1 - pow(centerLineFactor, 2)) / (1 + pow(centerLineFactor, 2)), -1), 1))
    }
    
    private var L: CGFloat {
        return centerLineFactor * 2
    }
    
    private var C: CGFloat {
        let r = tan(theta) * centerLineFactor
        return r * (CGFloat.pi / 2 + theta)
    }
    
    private var startPointTrackLength: CGFloat {
        return C + L + 2 * CGFloat.pi
    }
    
    private var endPointTrackLength: CGFloat {
        return 2 * L + C
    }
    
    private var endProgressPhase1: CGFloat {
        return L / endPointTrackLength
    }
    
    private var endProgressPhase2: CGFloat {
        return (L + C) / endPointTrackLength
    }
    
    private var startProgressPhase1: CGFloat {
        return 0
    }
    
    private var startProgressPhase2: CGFloat {
        return C / startPointTrackLength
    }
    
    //MARK: - Init
    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        guard let layer = layer as? CDCircledCrossLayer else { return }
        self.lineWidth = layer.lineWidth
        self.lineColor = layer.lineColor
        self.centerLineFactor = layer.centerLineFactor
        self.radius = layer.radius
        
        configure()
    }
    
    override static func needsDisplay(forKey: String) -> Bool {
        switch forKey {
        case "lineWidth":
            return true
        case "lineColor":
            return true
        case "centerLineFactor":
            return true
        case "radius":
            return true
        default:
            return super.needsDisplay(forKey: forKey)
        }
    }
    
    override func draw(in ctx: CGContext) {
        struct AngleRange {
            var start: CGFloat
            var end: CGFloat
            var scale: CGFloat = 1
            
            func progressed(progress: CGFloat) -> CGFloat {
                return start + (end - start) * progress * scale
            }
            
            func contains(_ value: CGFloat) -> Bool {
                return (value >= start && value <= end) || (value <= end && value >= start)
            }
        }
        
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        ctx.translateBy(x: bounds.midX, y: bounds.midY)
        
        // Flip y-Axis
        ctx.scaleBy(x: 1, y: -1)
        ctx.scaleBy(x: radius, y: radius)
        
        lineColor.setStroke()
        
        let L1 = startPointTrackLength
        let L2 = endPointTrackLength
        let r = tan(theta) * centerLineFactor
        let A = CGPoint(x: -centerLineFactor, y: 0)
        let B = CGPoint(x: centerLineFactor, y: 0)
        let O = CGPoint(x: B.x, y: r)
        let C = CGPoint(x: cos(theta), y: sin(theta))
        
        let angle1 = CGFloat.pi * 3 / 2
        let angle2 = angle1 + CGFloat.pi / 2 + theta
        let angle3 = theta
        let angle4 = theta + L
        
        let startRangeTiny = AngleRange(start: angle1, end: angle2, scale: L1 / self.C)
        let startRangeLarge = AngleRange(start: angle3, end: angle4, scale: L1 / self.C)
        
        let endRangeTiny = AngleRange(start: angle1, end: angle2, scale: L2 / self.C)
        let endRangeLarge = AngleRange(start: angle3, end: angle4, scale: L2 / self.C)
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth / radius
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        switch (progress, progress) {
        case (-CGFloat.infinity..<startProgressPhase2, -CGFloat.infinity..<endProgressPhase1):
            path.move(to: CGPoint(x: A.x + progress * L2 , y: 0))
            path.addLine(to: CGPoint(x: B.x + progress * L1, y: 0))
            break;
        case (startProgressPhase1..<startProgressPhase2, endProgressPhase1..<endProgressPhase2):
            break;
        case (startProgressPhase2..<CGFloat.infinity, -CGFloat.infinity..<endProgressPhase1):
            break;
        case (startProgressPhase2..<CGFloat.infinity, endProgressPhase1..<endProgressPhase2):
            break;
        case (startProgressPhase2..<CGFloat.infinity, endProgressPhase2..<CGFloat.infinity):
            break;
        default:
            break
        }
        
        lineColor.setStroke()
        path.stroke()
    }
    
    //MARK: - Configure
    private func configure() {
        setNeedsDisplay()
    }
}

class CDCircledCrossControl: UIControl {
    var isClosed = false
    
    func setClosed(animeted: Bool) {
    }
    
    var progress: CGFloat {
        get {
            return drawLayer.progress
        }
        set {
            drawLayer.progress = progress
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
    
    override static var layerClass: AnyClass {
        return CDCircledCrossLayer.self
    }
    
    private var drawLayer: CDCircledCrossLayer {
        return self.layer as! CDCircledCrossLayer
    }
    
    //MARK: - Configure
    private func configure() {
        backgroundColor = .clear
        layer.contentsScale = UIScreen.main.scale
    }
}
































