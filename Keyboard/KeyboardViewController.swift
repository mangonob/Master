//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by 高炼 on 2018/1/11.
//  Copyright © 2018年 高炼. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    lazy var keyboardController = KeyboardController()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        keyboardController.delegate = self
        
        addChildViewController(keyboardController)
        keyboardController.view.frame = view.bounds
        keyboardController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(keyboardController.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
    }

}


extension KeyboardViewController: KeyboardControllerDelegate {
}
