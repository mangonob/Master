//
//  CDBandagedBarButtonItem.swift
//  BaiShengUPlus
//
//  Created by 高炼 on 2017/9/27.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit

private class CDBandagedView: UIView {
    fileprivate lazy var bandgeButton = UIButton(type: .custom)
    
    fileprivate lazy var imageView = UIImageView()
    
    var cornerInset: UIEdgeInsets = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    var number: Int? {
        didSet {
            if let number = number {
                bandgeButton.setTitle("\(number > 99 ? "99+" : "\(number)")", for: .normal)
            } else {
                bandgeButton.setTitle(nil, for: .normal)
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        number = 10
    }
    
    //MARK: - Configure
    private var configureOnce = true
    private func configure() {
        guard configureOnce else { return }
        configureOnce = false
        
        imageView.contentMode = .scaleAspectFit
        
        bandgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        bandgeButton.backgroundColor = UIColor.red
        bandgeButton.setTitleColor(.white, for: .normal)
        
        addSubview(imageView)
        addSubview(bandgeButton)
        
        bandgeButton.contentEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 2)
        
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        bandgeButton.center = .init(x: bounds.maxX - cornerInset.right, y: cornerInset.top)
        let systemSize = bandgeButton.systemLayoutSizeFitting(.zero)
        bandgeButton.bounds = .init(origin: .zero, size: .init(width: max(systemSize.width, systemSize.height), height: systemSize.height))
        bandgeButton.layer.cornerRadius = min(bandgeButton.bounds.height, bandgeButton.bounds.width) / 2
    }
}

class CDBandagedBarButtonItem: UIBarButtonItem {
    private var bandgedView: CDBandagedView! {
        return customView as! CDBandagedView
    }
    
    var number: Int? {
        didSet {
            bandgedView.number = number
        }
    }
    
    var font: UIFont? {
        get {
            return bandgeButton.titleLabel?.font
        }
        set {
            bandgeButton.titleLabel?.font = font
        }
    }
    
    var bandgeButton: UIButton {
        return bandgedView.bandgeButton
    }
    
    var cornerInset: UIEdgeInsets = .zero {
        didSet {
            bandgedView.cornerInset = cornerInset
        }
    }
    

    override var image: UIImage? {
        get {
            return bandgedView.imageView.image
        }
        set {
            bandgedView.imageView.image = newValue
        }
    }
    
    convenience init(image: UIImage?, frame: CGRect = CGRect(origin: .zero, size: CGSize(width: 30, height: 30)), cornerInset: UIEdgeInsets = .zero) {
        let customView = CDBandagedView(frame: frame)
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















