//
//  Render.swift
//  Demo
//
//  Created by 高炼 on 2018/3/30.
//  Copyright © 2018年 高炼. All rights reserved.
//

import UIKit
import MetalKit

let aligned256UniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100

let maxBuffersInFlight = 3

enum RenderError: Error {
    case badVertexDescriptor
}


class Render: NSObject {
    weak var mtkView: MTKView!
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let dynamicUniformBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let texture: MTLTexture
    let uniforms: UnsafeMutablePointer<Uniforms>
    var projectionMatrix: matrix_float4x4 = matrix_float4x4()
    var ratation: Float = 0
    var mesh: MTKMesh

    init?(_ mtkView: MTKView) {
        self.mtkView = mtkView
        guard let viewDevice = mtkView.device else { return nil }
        device = viewDevice
        
        guard let queue = viewDevice.makeCommandQueue() else { return nil }
        commandQueue = queue
        
        guard let buffer = viewDevice .makeBuffer(length: aligned256UniformsSize * maxBuffersInFlight,
                                                  options: .storageModeShared) else { return nil }
        self.dynamicUniformBuffer = buffer

        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.isDepthWriteEnabled = true
        depthStateDescriptor.depthCompareFunction = .less
        guard let depthState = device.makeDepthStencilState(descriptor: depthStateDescriptor) else { return nil }
        self.depthState = depthState
    }
    
    /// Build a render pipeline state
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             mtkView: MTKView) throws -> MTLRenderPipelineState {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let des = MTLRenderPipelineDescriptor()
        des.label = "Render Pipeline"
        des.sampleCount = mtkView.sampleCount
        des.vertexFunction = vertexFunction
        des.fragmentFunction = fragmentFunction
        des.vertexDescriptor = buildVertexDescriptor()
        
        des.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        des.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        des.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: des)
    }
    
    class func buildMesh(device: MTLDevice,
                         vertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let mdlMesh = MDLMesh.newBox(withDimensions: float3(4, 4, 4),
                                     segments: uint3(2, 2, 2),
                                     geometryType: .triangles,
                                     inwardNormals: false,
                                     allocator: allocator)
        
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        
        guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else {
            throw RenderError.badVertexDescriptor
        }
        
        attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
        attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
        
        mdlMesh.vertexDescriptor = mdlVertexDescriptor
        
        return try MTKMesh(mesh: mdlMesh, device: device)
    }
    
    class func buildVertexDescriptor() -> MTLVertexDescriptor {
        let des = MTLVertexDescriptor()
        
        let positionAttribute = des.attributes[VertexAttribute.position.rawValue]
        let texcoordAttribute = des.attributes[VertexAttribute.texcoord.rawValue]
        
        positionAttribute?.format = .float3
        positionAttribute?.bufferIndex = BufferIndex.meshPositions.rawValue
        positionAttribute?.offset = 0

        texcoordAttribute?.format = .float2
        texcoordAttribute?.bufferIndex = BufferIndex.meshTexcoords.rawValue
        texcoordAttribute?.offset = 0
        
        let positionsBufferLayout = des.layouts[BufferIndex.meshPositions.rawValue]
        let texcoordsBufferLayout = des.layouts[BufferIndex.meshTexcoords.rawValue]
        
        positionsBufferLayout?.stepFunction = .perVertex
        positionsBufferLayout?.stepRate = 1
        positionsBufferLayout?.stride = 3 * MemoryLayout<Float>.size
        
        texcoordsBufferLayout?.stepFunction = .perVertex
        texcoordsBufferLayout?.stepRate = 1
        texcoordsBufferLayout?.stride = 2 * MemoryLayout<Float>.size

        return des
    }
}

extension Render: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        print(CACurrentMediaTime())
    }
}