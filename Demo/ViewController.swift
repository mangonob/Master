//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import Lottie


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panAction(_:))))
    }
    
    var isInteractiveTransitioning = false
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    var circleTransition: CDCircleTransition?
    
    func panAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)
        switch sender.state {
        case .began:
            isInteractiveTransitioning = true
            
            circleTransition = CDCircleTransition(startPoint: location)
            
            let vc = ViewController2()
            vc.view.backgroundColor = UIColor.flatGreen
            navigationController?.pushViewController(vc, animated: true)
            
        case .changed:
            if let progress = circleTransition?.progress(at: location) {
                interactiveTransition?.update(progress)
            }
        default:
            circleTransition?.transitionContext.containerView.layer.beginTime = CACurrentMediaTime()
            
            interactiveTransition?.cancel()
            circleTransition?.transitionContext.containerView.layer.speed = -1
            
            isInteractiveTransitioning = false
            interactiveTransition = nil
            circleTransition = nil
        }
    }
}


extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circleTransition?.operation = operation
        return circleTransition ?? CDCircleTransition(operation: operation, startPoint: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if isInteractiveTransitioning {
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            return interactiveTransition
        } else {
            return nil
        }
    }
}

