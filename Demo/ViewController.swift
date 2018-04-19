//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 2017/12/29.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import Metal
import simd
import MetalKit
import ModelIO

class ViewController: UIViewController {
    var render: Render!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = view as? MTKView else {
            return
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = .clear
        
        render = Render(mtkView)
        
        mtkView.delegate = render
        
        render.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
        ///
        let modelBundle = Bundle.init(url: Bundle.main.url(forResource: "Model", withExtension: "bundle")!)!
        let asset = MDLAsset.init(url: modelBundle.url(forResource: "Temple", withExtension: "obj")!)
        let mesh = asset.object(at: 0) as! MDLMesh
        let submeshes = mesh.submeshes as! [MDLSubmesh]
        submeshes.forEach { (submesh) in
            if #available(iOS 11.0, *) {
                submesh.material?.properties(with: .ambientOcclusion).forEach({ (property) in
                    print(property.urlValue)
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


