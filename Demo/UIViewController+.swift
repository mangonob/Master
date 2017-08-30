//
//  UIViewController+.swift
//  B2B-Seller
//
//  Created by 高炼 on 16/12/27.
//  Copyright © 2016年 杨彪. All rights reserved.
//

import UIKit

private let defaultDuration = 0.3

extension UIViewController {
    func fadeIn() {
        let root = UIApplication.shared.keyWindow?.rootViewController
        fadeIn(viewController: root)
    }
    
    func fadeIn(viewController: UIViewController?) {
        fadeIn(duration: defaultDuration, inViewController: viewController, completed: nil)
    }
    
    func fadeIn(duration: CFTimeInterval?, inViewController viewController: UIViewController?, completed: (()->Void)? ){
        let duration = duration ?? defaultDuration
        viewController?.addChildViewController(self)
        viewController?.view.addSubview(view)
        if let frame = viewController?.view.bounds {
            view.frame = frame
        }
        
        view.alpha = 0
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.alpha = 1
        }) { (_) in
            completed?()
        }
        
    }
    
    func fadeOut() {
        fadeOut(with: nil, completed: nil)
    }
    
    func fadeOut(with duration: CFTimeInterval?, completed: (()->Void)? ) {
        let duration = duration ?? defaultDuration
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.alpha = 0
        }, completion: { [weak self] (_) in
            self?.view.removeFromSuperview()
            self?.removeFromParentViewController()
            completed?()
        })
    }
    
    // None Animation
    func showIn() {
        let root = UIApplication.shared.keyWindow?.rootViewController
        showIn(viewController: root)
    }
    
    func showIn(viewController: UIViewController?) {
        viewController?.addChildViewController(self)
        viewController?.view.addSubview(view)
        if let frame = viewController?.view.bounds {
            view.frame = frame
        }
    }
    
    func showOut() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

extension UIViewController {
    class func loadFromStoryBoard() -> Self {
        let name = String.init(describing: self)
        return genericGateway(self, storyboardName: name)
    }
    
    private class func genericGateway<T: UIViewController>(_ type: T.Type, storyboardName: String) -> T {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() as! T
    }
    
    var isCurrent: Bool {
        return isViewLoaded && view.window != nil
    }
    
    var furtherNavigationController: UINavigationController? {
        return tabBarController?.furtherNavigationController ?? navigationController?.furtherNavigationController ?? navigationController
    }
}





























