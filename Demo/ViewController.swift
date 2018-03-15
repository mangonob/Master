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
            
            let positions: [Float] = [
                -1.0, 1.0, 0.0, 1.0,
                1.0, 1.0, 0.0, 1.0,
                -1.0, -1.0, 0.0, 1.0,
                1.0, -1.0, 0.0, 1.0,
                ]

            let colors: [Float] = [
                1.0, 0.0, 0.0, 1.0,
                0.0, 1.0, 0.0, 1.0,
                0.0, 0.0, 1.0, 1.0,
                1.0, 1.0, 0.0, 1.0,
            ]

            let positionBuffer = device.makeBuffer(bytes: positions, length: positions.count * MemoryLayout<Float>.size, options: [])
            let colorsBuffer = device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<Float>.size, options: [])

            let defaultLibrary = device.makeDefaultLibrary()
            let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
            let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[0].format = .float4
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[1].bufferIndex = 1
            vertexDescriptor.attributes[1].format = .float4
            vertexDescriptor.attributes[1].offset = 0
            vertexDescriptor.layouts[0].stride = MemoryLayout<float4>.stride
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            vertexDescriptor.layouts[1].stride = MemoryLayout<float4>.stride
            vertexDescriptor.layouts[1].stepFunction = .perVertex
            
            pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
            
            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

            metalLayer?.device = device

            if let drawable = metalLayer?.nextDrawable() {
                let renderPassDescriptor = MTLRenderPassDescriptor()
                renderPassDescriptor.colorAttachments[0].texture = drawable.texture
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 1)

                let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                encoder?.setRenderPipelineState(pipelineState)
                encoder?.setVertexBuffer(positionBuffer, offset: 0, index: 0)
                encoder?.setVertexBuffer(colorsBuffer, offset: 0, index: 1)
                encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: colors.count / 4, instanceCount: 1)
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


