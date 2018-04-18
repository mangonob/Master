//
//  Render.swift
//  Demo
//
//  Created by 高炼 on 2018/3/30.
//  Copyright © 2018年 高炼. All rights reserved.
//

import UIKit
import MetalKit
import simd

let aligned256UniformsSize = (MemoryLayout<Uniforms>.size & ~0xFF) + 0x100

let maxBuffersInFlight = 3

let segments = uint2(2, 1)

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
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    var uniformBufferOffset = 0
    
    var uniformBufferIndex = 0
    
    var uniforms: UnsafeMutablePointer<Uniforms>
    var projectionMatrix = matrix_float4x4()
    var rotation: Float = 0
    var mesh: MTKMesh!
    var vertexDescriptor: MTLVertexDescriptor
    
    static var segmentFactor: UInt32 = 0
    
    init?(_ mtkView: MTKView) {
        self.mtkView = mtkView
        guard let device = mtkView.device else { return nil }
        self.device = device
        
        guard let queue = device.makeCommandQueue() else { return nil }
        commandQueue = queue
        
        guard let uniformBuffer =
            device.makeBuffer(length: aligned256UniformsSize * maxBuffersInFlight,
                              options: .storageModeShared) else { return nil }
        
        self.dynamicUniformBuffer = uniformBuffer
        
        uniforms = UnsafeMutableRawPointer(uniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
        
        mtkView.depthStencilPixelFormat = .depth32Float_stencil8
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.sampleCount = 1
        
        vertexDescriptor = Render.buildVertexDescriptor()
        
        do {
            pipelineState = try
                Render.buildRenderPipelineWithDevice(device: device,
                                                     mtkView: mtkView,
                                                     vertexDescriptor: vertexDescriptor)
        } catch {
            print("Unable to compile render pipeline state. Error info: \(error)")
            return nil
        }
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.isDepthWriteEnabled = true
        depthStateDescriptor.depthCompareFunction = .less
        
        guard let depthState = device.makeDepthStencilState(descriptor: depthStateDescriptor) else { return nil }
        self.depthState = depthState
        
        do {
            texture = try Render.loadTexture(device: device, textureName: "Earth")
        } catch {
            print("Unable to load texture. Error info: \(error)")
            return nil
        }
        
        super.init()
    }
    
    /// Build a render pipeline state
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             mtkView: MTKView,
                                             vertexDescriptor: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let des = MTLRenderPipelineDescriptor()
        des.label = "Render Pipeline"
        des.sampleCount = mtkView.sampleCount
        des.vertexFunction = vertexFunction
        des.fragmentFunction = fragmentFunction
        des.vertexDescriptor = vertexDescriptor
        
        des.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        des.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        des.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: des)
    }
    
    class func buildMesh(device: MTLDevice,
                         vertexDescriptor: MTLVertexDescriptor) throws -> MTKMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let mdlMesh =
            MDLMesh.init(sphereWithExtent: float3(2, 2, 2),
                         segments: segments &* segmentFactor,
                         inwardNormals: true,
                         geometryType: .triangles,
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
    
    /// Load texture data
    class func loadTexture(device: MTLDevice,
                           textureName: String) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        
        let options: [MTKTextureLoader.Option: Any] = [
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            .textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        return try textureLoader.newTexture(name: textureName,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: options)
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
    
    private func updateDynamicBuffeState() {
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        uniformBufferOffset = aligned256UniformsSize * uniformBufferIndex
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset)
            .bindMemory(to: Uniforms.self, capacity: 1)
    }
    
    private func updateModelViewMatrix() {
        uniforms[0].projectionMatrix = projectionMatrix
        
        let rotationAxis = float3(0, 1, 0)
        
        let modelMatrix = matrix4x4_rotation(radians: deg2rad(23.9), axis: float3(0, 0, -1))
            * matrix4x4_rotation(radians: rotation, axis: rotationAxis)
        
        let viewMatrix = matrix4x4_translation(0, 0, -8)
        
        uniforms[0].modelViewMatrix = viewMatrix * modelMatrix
        
        rotation += 0.01
    }
}

extension Render: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(size.width) / Float(size.height)
        projectionMatrix = matrix_perspective_right_hand(fovyRadians: deg2rad(65), aspectRatio:aspect, nearZ: 0.1, farZ: 100)
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        /** wait semaphore */
        _ = inFlightSemaphore.wait(timeout: .distantFuture)
        
        defer { commandBuffer.commit() }

        do {
            mesh = try Render.buildMesh(device: device, vertexDescriptor: vertexDescriptor)
        } catch {
            print("Unable to build MetalKit Mesh. Error info: \(error)")
            return
        }
        
        commandBuffer.addCompletedHandler({ [weak inFlightSemaphore] (_) in
            inFlightSemaphore?.signal()
        })

        updateDynamicBuffeState()
        updateModelViewMatrix()
        
        renderEncoder.label = "Primary Render Encoder"
        renderEncoder.pushDebugGroup("Draw Ball")
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setTriangleFillMode(.lines)
        
        renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        renderEncoder.setFragmentBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        
        let vertexBuffersCount = mesh.vertexBuffers.count
        renderEncoder.setVertexBuffers(mesh.vertexBuffers.map { $0.buffer },
                                       offsets: .init(repeating: 0, count: vertexBuffersCount),
                                       range: 0..<vertexBuffersCount)
        
        renderEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)

        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
        
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
    }
}
