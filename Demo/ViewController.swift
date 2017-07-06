//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import ImageIO
import MediaPlayer
import AVKit
import AssetsLibrary


class AVPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    override var layer: AVPlayerLayer {
        return super.layer as! AVPlayerLayer
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }.forEach { print($0) }
        
        let v = UIView()
        v.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: 0.5))
        v.backgroundColor = UIColor.lightGray
        textField.inputAccessoryView = v
        // Do any additional setup after loading the view, typically from a nib.
    }
}














