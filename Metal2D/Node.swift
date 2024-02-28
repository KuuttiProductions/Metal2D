//
//  Node.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Node {
    
    var name: String
    var texture: MTLTexture!
    var render: Bool = true
    
    var position: simd_float2 = simd_float2(0.0, 0.0)
    var rotation: Float = 0.0
    var scale: simd_float2 = simd_float2(1.0, 1.0)
    
    var time: Float = 0.0
    
    var modelConstant = ModelConstant()
    var modelMatrix: simd_float3x3 {
        var modelMatrix = matrix_identity_float3x3
        modelMatrix.translate(by: position)
        modelMatrix.rotate(angle: rotation)
        modelMatrix.scale(by: scale)
        return modelMatrix
    }
    
    var mesh: [Vertex] = [
        Vertex(position: simd_float2(-1.0, -1.0), textureCoordinate: simd_float2(0, 1)),
        Vertex(position: simd_float2( 0.0,  1.0), textureCoordinate: simd_float2(0.5, 0)),
        Vertex(position: simd_float2( 1.0, -1.0), textureCoordinate: simd_float2(1, 1))
    ]
    
    init(name: String) {
        self.name = name
        loadTexture()
    }
    
    func loadTexture() {
        let url = Bundle.main.url(forResource: "Texture", withExtension: "png")
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: Core.device)
        
        texture = try! textureLoader.newTexture(URL: url!)
    }
    
    func update(deltaTime: Float) {
        tick(deltaTime: deltaTime)
        time += deltaTime
        modelConstant.modelMatrix = modelMatrix
    }
    
    func tick(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        if !render { return }
        renderCommandEncoder.setVertexBytes(&mesh, length: Vertex.stride(3), index: 0)
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}
