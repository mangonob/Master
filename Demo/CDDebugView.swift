//
//  CDDebugView.swift
//  Demo
//
//  Created by 高炼 on 17/6/13.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

class CDDebugView: UITextView {
    //MARK: - Init
    init() {
        super.init(frame: .zero, textContainer: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        layer.borderColor = UIColor.darkGray.withAlphaComponent(0.8).cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 7
        font = UIFont(name: "Menlo-Regular", size: 12)
        isSelectable = false
        isEditable = true
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        textColor = UIColor.gray
        
        autocorrectionType = .no
        
        addGestureRecognizer({
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clearAction(_:)))
            gesture.numberOfTapsRequired = 2
            return gesture
        }())
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func clear() {
        text = "======== Clear ========"
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect(x: 100, y: 100, width: 100, height: 100)
    }
    
    override var hasText: Bool {
        return false
    }
    
    func log(_ string: String) {
        text.append(string)
    }
    
    func logn(_ string: String) {
        text.append("\n\(string)")
    }
    
    //MARK: - Action
    func clearAction(_ sender: UITapGestureRecognizer) {
        logn("askdjlasdjf")
    }
    
    override func insertText(_ text: String) {
    }
    
    override func deleteBackward() {
    }
    
    override func replace(_ range: UITextRange, withText text: String) {
    }
}


