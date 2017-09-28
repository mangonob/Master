//
//  CTBadgeBarButtonItem.swift
//  BaiShengUPlus
//
//  Created by 高炼 on 2017/9/27.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit

private class CTBadgeView: UIView {
    fileprivate lazy var badgeButton = UIButton(type: .custom)
    
    fileprivate lazy var imageView = UIImageView()
    
    var cornerInset: UIEdgeInsets = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    var number: Int? {
        didSet {
            if let number = number {
                badgeButton.setTitle("\(number > 99 ? "99+" : "\(number)")", for: .normal)
                badgeButton.alpha = 1
            } else {
                badgeButton.setTitle(nil, for: .normal)
                badgeButton.alpha = 0
            }
            
            layoutSubviews()
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
    
    //MARK: - Configure
    private var configureOnce = true
    private func configure() {
        guard configureOnce else { return }
        configureOnce = false
        
        imageView.contentMode = .scaleAspectFit
        
        badgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        badgeButton.backgroundColor = UIColor.red
        badgeButton.setTitleColor(.white, for: .normal)
        
        addSubview(imageView)
        addSubview(badgeButton)
        
        badgeButton.contentEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 4)
        
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        badgeButton.center = .init(x: bounds.maxX - cornerInset.right, y: cornerInset.top)
        let systemSize = badgeButton.systemLayoutSizeFitting(.zero)
        badgeButton.bounds = .init(origin: .zero, size: .init(width: max(systemSize.width, systemSize.height), height: systemSize.height))
        badgeButton.layer.cornerRadius = min(badgeButton.bounds.height, badgeButton.bounds.width) / 2
    }
}

class CTBadgeBarButtonItem: UIBarButtonItem {
    private var badgeView: CTBadgeView! {
        return customView as! CTBadgeView
    }
    
    var number: Int? {
        didSet {
            badgeView.number = number
        }
    }
    
    func setNumber(_ number: Int?, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.number = number
            }
        } else {
            self.number = number
        }
    }
    
    var font: UIFont? {
        get {
            return badgeButton.titleLabel?.font
        }
        set {
            badgeButton.titleLabel?.font = newValue
        }
    }
    
    var badgeButton: UIButton {
        return badgeView.badgeButton
    }
    
    var cornerInset: UIEdgeInsets = .zero {
        didSet {
            badgeView.cornerInset = cornerInset
        }
    }
    

    override var image: UIImage? {
        get {
            return badgeView.imageView.image
        }
        set {
            badgeView.imageView.image = newValue
        }
    }
    
    convenience init(image: UIImage?, frame: CGRect = CGRect(origin: .zero, size: CGSize(width: 30, height: 30)), cornerInset: UIEdgeInsets = .zero) {
        let customView = CTBadgeView(frame: frame)
        customView.cornerInset = cornerInset
        customView.imageView.image = image
        
        self.init(customView: customView)
        self.cornerInset = cornerInset
    }
    
    private override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}















