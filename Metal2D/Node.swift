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
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        renderCommandEncoder.setVertexBytes(&mesh, length: Vertex.stride(3), index: 0)
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}
