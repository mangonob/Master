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

class ViewController: UIViewController {
    var metalLayer: CAMetalLayer? {
        return view.layer as? CAMetalLayer
    }
    
    var pipelineState: MTLRenderPipelineState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.shared.isStatusBarHidden = true
        
        if let device = MTLCreateSystemDefaultDevice(),
            let queue = device.makeCommandQueue(),
            let commandBuffer = queue.makeCommandBuffer(),
            let library = device.makeDefaultLibrary() {

            var vertexBuffer: MTLBuffer! = nil
            let vertexData: [Float] = [
                -0.5, 1.0, 0.0,
                -1.0, 0.0, 0.0,
                0.0, 0.5, 0.0,
                0.5, 0.0, 0.0,
                0.0, -1.0, 0.0,
                1.0, -0.5, 0.0,
            ]
            
            vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])
            
            let defaultLibrary = device.makeDefaultLibrary()
            let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
            let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            metalLayer?.device = device
            
            if let drawable = metalLayer?.nextDrawable() {
                let renderPassDescriptor = MTLRenderPassDescriptor()
                renderPassDescriptor.colorAttachments[0].texture = drawable.texture
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 1, blue: 0, alpha: 1)

                let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                encoder?.setRenderPipelineState(pipelineState)
                encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                encoder?.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: vertexData.count / 3, instanceCount: 1)
                encoder?.endEncoding()
                
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


