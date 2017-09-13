//
//  CDCircleTransition.swift
//  Demo
//
//  Created by Trinity on 2017/9/14.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDCircleTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval
    var operation: UINavigationControllerOperation
    var startPoint: CGPoint
    
    var transitionContext: UIViewControllerContextTransitioning!
    
    var radius: CGFloat = 0
    
    init(duration: TimeInterval = 0.33,
         operation: UINavigationControllerOperation = .none,
         startPoint: CGPoint = .zero) {
        self.duration = duration
        self.operation = operation
        self.startPoint = startPoint
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func progress(at point: CGPoint) -> CGFloat {
        let delta = CGVector(dx: point.x - startPoint.x, dy: point.y - startPoint.y)
        return min(max(sqrt(delta.dx * delta.dx + delta.dy * delta.dy) / radius, 0), 1)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.view(forKey: .from) else { return }
        guard let to = transitionContext.view(forKey: .to) else { return }
        
        self.transitionContext = transitionContext
        
        let container = transitionContext.containerView
        
        let tinyCircle = UIBezierPath(ovalIn: CGRect(center: startPoint, width: 0, height: 0)).cgPath
        
        let points: [CGPoint] = [ CGPoint.zero,
                                  CGPoint(x: 0, y: container.bounds.maxY),
                                  CGPoint(x: container.bounds.maxX, y: 0),
                                  CGPoint(x: container.bounds.maxX, y: container.bounds.maxY) ]
        
        let radiues = points.map { CGVector(dx: $0.x - startPoint.x, dy: $0.y - startPoint.y) }
            .map { sqrt($0.dx * $0.dx + $0.dy * $0.dy) }
        
        radius = radiues.max()!
        
        let bigCircle = UIBezierPath(ovalIn: CGRect(center: startPoint, width: radius * 2, height: radius * 2))
            .cgPath
        
        let mask = CAShapeLayer()
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        switch operation {
        case .push:
            container.addSubview(from)
            container.addSubview(to)
            to.layer.mask = mask
            animation.fromValue = tinyCircle
            animation.toValue = bigCircle
            mask.path = bigCircle
        case .pop:
            container.addSubview(to)
            container.addSubview(from)
            from.layer.mask = mask
            animation.fromValue = bigCircle
            animation.toValue = tinyCircle
            mask.path = tinyCircle
        default:
            break
        }
        
        mask.add(animation, forKey: nil)
    }
}


extension CDCircleTransition: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        transitionContext?.completeTransition(!transitionContext.transitionWasCancelled)
    }
}






























