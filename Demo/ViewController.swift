//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import CoreText
import MBProgressHUD


/// 定义 `protocol`
public protocol SelfAware: class {
    static func awake()
}

// 创建代理执行单例
class NothingToSeeHere{
    
    static func harmlessFunction(){
        let typeCount = Int(objc_getClassList(nil, 0))
        let  types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass?>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount)) //获取所有的类
        for index in 0 ..< typeCount{
            (types[index] as? SelfAware.Type)?.awake() //如果该类实现了SelfAware协议，那么调用awake方法
        }
        types.deallocate(capacity: typeCount)
    }
}

/// 执行单例
extension UIApplication {
    public static let runOnce:Void = {
        //使用静态属性以保证只调用一次(该属性是个方法)
        NothingToSeeHere.harmlessFunction()
    }()
    
    open override var next: UIResponder?{
        UIApplication.runOnce
        return super.next
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension UIViewController: SelfAware {
    private static let awakeOnce: Void = {
        let defaultImp = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidLoad))
        
        let xxxImp = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.xxx_viewDidLoad))
        
        method_exchangeImplementations(defaultImp, xxxImp)
    }()
    
    public static func awake() {
        awakeOnce
    }
    
    func xxx_viewDidLoad() {
        self.xxx_viewDidLoad()
        
        print("\(self) Did Load!")
    }
}
