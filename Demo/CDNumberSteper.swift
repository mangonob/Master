//
//  CDNumberSteperView.swift
//  B2B-Seller
//
//  Created by 高炼 on 2017/7/5.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit
import ChameleonFramework

private let marginDistance: CGFloat = 30
private let subTag = 1025
private let addTag = 1026

class CDNumberSteper: UIControl {
    var minTextFieldWidth: CGFloat = 44 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: max(textField.intrinsicContentSize.width + 8, minTextFieldWidth) + 2 * marginDistance,
                      height: bounds.height)
    }
    
    var value: Int? {
        get {
            return Int(textField.text ?? "")
        }
        set {
            textField.text = newValue?.description
            sendActions(for: .valueChanged)
        }
    }
    
    private var displaylink: CADisplayLink!
    private var isAdding = false
    
    var minValue = 0
    var maxValue = Int.max
    
    lazy var textField = UITextField()
    let indicatorLabel = UILabel()
    
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
    private func configure() {
        backgroundColor = .clear
        
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        
        textField.frame = bounds.insetBy(dx: marginDistance, dy: 0)
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor(hexString: "DDDDDD")!
        textField.borderStyle = .none
        
        addSubview(textField)
        
        let button1 = UIButton(frame: bounds.divided(atDistance: marginDistance, from: .minXEdge).slice)
        button1.setTitle("-", for: .normal)
        button1.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
        button1.setTitleColor(.darkGray, for: .normal)
        button1.tag = subTag
        addSubview(button1)
        button1.addTarget(self, action: #selector(self.subAction(sender:)), for: .touchUpInside)
        button1.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(sender:))))
        
        let button2 = UIButton(frame: bounds.divided(atDistance: marginDistance, from: .maxXEdge).slice)
        button2.setTitle("+", for: .normal)
        button2.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        button2.setTitleColor(.darkGray, for: .normal)
        button2.tag = addTag
        addSubview(button2)
        button2.addTarget(self, action: #selector(self.addAction(sender:)), for: .touchUpInside)
        button2.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(sender:))))
        
        let v = UIView()
        v.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 60))
        v.backgroundColor = UIColor(hexString: "D7DADF")!
        
        let dividend = v.bounds.divided(atDistance: 80, from: .maxXEdge)
        indicatorLabel.frame = dividend.remainder.divided(atDistance: 8, from: .minXEdge).remainder
        
        let size: CGFloat = 40
        
        indicatorLabel.font =
            UIFont(name: "PingFangSC-Thin", size: size) ??
            UIFont(name: "PingFangSC-Thin", size: size) ??
            UIFont.systemFont(ofSize: size)
        
        indicatorLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorLabel.adjustsFontSizeToFitWidth = true
        indicatorLabel.minimumScaleFactor = 0.5
        
        v.addSubview(indicatorLabel)
        textField.inputAccessoryView = v
        
        let doneButton = UIButton(type: .system)
        doneButton.frame = dividend.slice
        doneButton.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        doneButton.setTitle("确定", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        v.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(self.doneAction(sender:)), for: .touchUpInside)
        
        let sep = UIView()
        sep.frame = bounds
        sep.frame.size.height = 0.5
        sep.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        sep.backgroundColor = .lightGray
        v.addSubview(sep)
        
        textField.addTarget(self, action: #selector(self.textChangeAction(sender:)), for: .editingChanged)
    }
    
    func longPressAction(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isAdding = (sender.view?.tag ?? 0) == addTag
            displaylink = CADisplayLink(target: self, selector: #selector(self.displayLinkAction(sender:)))
            displaylink.frameInterval = 2
            displaylink.add(to: RunLoop.main, forMode: .commonModes)
        case .cancelled, .ended, .failed:
            displaylink.remove(from: RunLoop.main, forMode: .commonModes)
            displaylink.invalidate()
            displaylink = nil
        default:
            break
        }
    }
    
    func displayLinkAction(sender: CADisplayLink) {
        if isAdding {
            addAction(sender: nil)
        } else {
            subAction(sender: nil)
        }
    }
    
    func subAction(sender: UIButton?) {
        if let value = value {
            self.value = max(value - 1, minValue)
            textField.sendActions(for: .editingChanged)
        }
    }
    
    func addAction(sender: UIButton?) {
        if let value = value {
            self.value = min(value + 1, maxValue)
            textField.sendActions(for: .editingChanged)
        }
    }
    
    func doneAction(sender: UIButton) {
        textField.resignFirstResponder()
    }
    
    func textChangeAction(sender: UITextField) {
        indicatorLabel.text = sender.text
        sendActions(for: .valueChanged)
        invalidateIntrinsicContentSize()
    }
}
