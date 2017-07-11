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
    var lineWidth: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineColor: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var centerLineFactor: CGFloat = sqrt(3) / 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var radius: CGFloat = 30 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
        case "progress":
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
            
            func progressed(_ progress: CGFloat) -> CGFloat {
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
        
        let angle1 = CGFloat.pi * 3 / 2
        let angle2 = angle1 + CGFloat.pi / 2 + theta
        let angle3 = theta
        let angle4 = theta + L
        
        let startRangeTiny = AngleRange(start: angle1, end: angle2, scale: L1 / self.C)
        let startRangeLarge = AngleRange(start: angle3, end: angle4 + CGFloat.pi * 2, scale: L1 / (self.L + CGFloat.pi * 2))
        
        let endRangeTiny = AngleRange(start: angle1, end: angle2, scale: L2 / self.C)
        let endRangeLarge = AngleRange(start: angle3, end: angle4, scale: L2 / self.L)
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth / radius
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        switch (progress, progress) {
        case (-CGFloat.infinity...startProgressPhase1, -CGFloat.infinity..<endProgressPhase1):
            path.move(to: CGPoint(x: A.x + progress * L2 , y: 0))
            path.addLine(to: CGPoint(x: B.x + progress * L1, y: 0))
        case (startProgressPhase1..<startProgressPhase2, -CGFloat.infinity..<endProgressPhase1):
            path.move(to: CGPoint(x: A.x + progress * L2, y: 0))
            path.addLine(to: B)
            path.addArc(withCenter: O, radius: r, startAngle: startRangeTiny.start, endAngle: startRangeTiny.progressed(progress - startProgressPhase1), clockwise: true)
        case (startProgressPhase1..<startProgressPhase2, endProgressPhase1..<endProgressPhase2):
            path.addArc(withCenter: O, radius: r, startAngle: endRangeTiny.progressed(progress - endProgressPhase1), endAngle: startRangeTiny.progressed(progress - startProgressPhase1), clockwise: true)
        case (startProgressPhase2..<CGFloat.infinity, -CGFloat.infinity..<endProgressPhase1):
            path.move(to: CGPoint(x: A.x + progress * L2, y: 0))
            path.addLine(to: B)
            path.addArc(withCenter: O, radius: r, startAngle: startRangeTiny.start, endAngle: startRangeTiny.end, clockwise: true)
            path.addArc(withCenter: .zero, radius: 1, startAngle: startRangeLarge.start, endAngle: startRangeLarge.progressed(progress - startProgressPhase2), clockwise: true)
        case (startProgressPhase2..<CGFloat.infinity, endProgressPhase1..<endProgressPhase2):
            path.addArc(withCenter: O, radius: r, startAngle: endRangeTiny.progressed(progress - endProgressPhase1), endAngle: endRangeTiny.end, clockwise: true)
            path.addArc(withCenter: .zero, radius: 1, startAngle: startRangeLarge.start, endAngle: startRangeLarge.progressed(progress - startProgressPhase2), clockwise: true)
            break;
        case (startProgressPhase2..<CGFloat.infinity, endProgressPhase2..<CGFloat.infinity):
            path.addArc(withCenter: .zero, radius: 1, startAngle: endRangeLarge.progressed(progress - endProgressPhase2), endAngle: startRangeLarge.progressed(progress - startProgressPhase2), clockwise: true)
        default:
            break
        }
        
        lineColor.setStroke()
        path.stroke()
        
        path.removeAllPoints()
        
        path.move(to: A)
        path.addLine(to: B)
        
        let H = kCDCircledCrossRaito * centerLineFactor
        let reverse = 1 - progress
        
        ctx.saveGState()
        ctx.translateBy(x: 0, y: H * reverse)
        ctx.rotate(by: CGFloat.pi / 4 * progress)
        path.stroke()
        ctx.restoreGState()
        
        ctx.saveGState()
        ctx.translateBy(x: 0, y: -H * reverse)
        ctx.rotate(by: -CGFloat.pi / 4 * progress)
        path.stroke()
        ctx.restoreGState()
    }
    
    //MARK: - Configure
    private func configure() {
        setNeedsDisplay()
    }
}

class CDCircledCrossControl: UIControl {
    func setClosed(_ closed: Bool, animated: Bool) {
        if animated {
            drawLayer.removeAllAnimations()
            let ani = CASpringAnimation(keyPath: "progress")
            ani.fromValue = closed ? 0 : 1
            ani.toValue = closed ? 1 : 0
            ani.duration = ani.settlingDuration
            isClosed = closed
            drawLayer.add(ani, forKey: nil)
        } else {
            isClosed = closed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let location = touches.first?.location(in: self) else { return }
        if bounds.contains(location) {
            setClosed(!isClosed, animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    var isClosed = false {
        didSet {
            if isClosed {
                progress = 1
            } else {
                progress = 0
            }
        }
    }
    
    var progress: CGFloat {
        get {
            return drawLayer.progress
        }
        set {
            drawLayer.progress = newValue
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            drawLayer.lineColor = tintColor
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
        drawLayer.lineColor = tintColor
        contentMode = .redraw
    }
}
































