//
//  PaintView.swift
//  Demo
//
//  Created by 高炼 on 2017/8/16.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class PaintView: UIView {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    //MARK: - Init
    var points = [CGPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        points.append(CGPoint(x: -1, y: -1))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let location = touches.first?.location(in: self) {
            points.append(location)
        }
    }
    
    //MARK: - Configure
    private func configure() {
        isMultipleTouchEnabled = true
        clearsContextBeforeDrawing = false
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction(sender:)))
        doubleTap.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTap)
    }
    
    func doubleTapAction(sender: UITapGestureRecognizer) {
        points.removeAll()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let paths = points.split(separator: CGPoint(x: -1, y: -1)).map { (points) -> UIBezierPath in
            let path = UIBezierPath()
            path.lineWidth = 20
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            if let first = points.first {
                path.move(to: first)
            }
            
            points.forEach { path.addLine(to: $0) }
            return path
        }
        
        paths.forEach { $0.stroke() }
    }
}





























