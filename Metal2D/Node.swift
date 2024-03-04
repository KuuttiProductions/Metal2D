//
//  Node.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Node {
    
    var name: String
    var texture: String!
    var mesh: MeshType = .Quad
    var matColor: simd_float4 = simd_float4(1, 1, 1, 1)
    var render: Bool = true
    
    var position: simd_float2 = simd_float2(0.0, 0.0)
    var rotation: Float = 0.0
    var scale: simd_float2 = simd_float2(1.0, 1.0)
    var depth: Int = 500
    
    var time: Float = 0.0
    
    var modelConstant = ModelConstant()
    var modelMatrix: simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(by: position)
        modelMatrix.rotate(angle: rotation)
        modelMatrix.scale(by: scale)
        return modelMatrix
    }
    
    init(name: String, mesh: MeshType = .Quad) {
        self.name = name
        self.mesh = mesh
    }
    
    func update(deltaTime: Float) {
        time += deltaTime
        tick(deltaTime: deltaTime)
        modelConstant.modelMatrix = modelMatrix
        modelConstant.depth = simd_clamp(Float(depth) / 1000, 0.0, 1.0) * 0.9
    }
    
    func tick(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        if !render { return }
        renderCommandEncoder.pushDebugGroup("Rendering \(name)")
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.getPipelineState(key: .Basic))
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&matColor, length: simd_float4.stride, index: 0)
        renderCommandEncoder.setFragmentTexture(TextureLibrary.getTexture(key: texture), index: 0)
        MeshLibrary.getMesh(key: mesh).draw(renderCommandEncoder: renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
}
