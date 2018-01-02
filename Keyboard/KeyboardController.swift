//
//  KeyboardController.swift
//  Keyboard
//
//  Created by 高炼 on 2018/1/11.
//  Copyright © 2018年 高炼. All rights reserved.
//

import UIKit

@objc protocol KeyboardControllerDelegate: UITextInputDelegate {
}

class KeyboardController: UIViewController {
    weak var delegate: KeyboardControllerDelegate?
    
    @IBOutlet weak var nextButton: UIButton!
    
    var keyboardViewController: KeyboardViewController! {
        return delegate as! KeyboardViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nextButton.addTarget(keyboardViewController, action: #selector(KeyboardViewController.handleInputModeList(from:with:)), for: .allTouchEvents)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
