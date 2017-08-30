//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import SpriteKit
import Metal
import MetalKit
import ChameleonFramework


class ViewController: CTTableController {
    private var _items = [
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
        Item(controllerType: ContentController.self),
    ]
    
    override var items: [CTTableController.Item] {
        return _items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
