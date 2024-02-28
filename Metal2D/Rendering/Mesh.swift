//
//  Mesh.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

class Mesh {
    var vertices: [Vertex] = []
    
    init() {
        addVertices()
    }
    
    func addVertices() {}
    
    func draw(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBytes(&vertices, length: Vertex.stride(vertices.count), index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}

class TriangleMesh: Mesh {
    override func addVertices() {
        self.vertices = [
            Vertex(position: simd_float2(-1.0, -1.0), textureCoordinate: simd_float2(0, 1)),
            Vertex(position: simd_float2( 0.0,  1.0), textureCoordinate: simd_float2(0.5, 0)),
            Vertex(position: simd_float2( 1.0, -1.0), textureCoordinate: simd_float2(1, 1))
        ]
    }
}

class QuadMesh: Mesh {
    override func addVertices() {
        self.vertices = [
            Vertex(position: simd_float2(-1.0, -1.0), textureCoordinate: simd_float2(0, 1)),
            Vertex(position: simd_float2( 1.0, -1.0), textureCoordinate: simd_float2(1, 1)),
            Vertex(position: simd_float2(-1.0,  1.0), textureCoordinate: simd_float2(0, 0)),
            Vertex(position: simd_float2(-1.0,  1.0), textureCoordinate: simd_float2(0, 0)),
            Vertex(position: simd_float2( 1.0, -1.0), textureCoordinate: simd_float2(1, 1)),
            Vertex(position: simd_float2( 1.0,  1.0), textureCoordinate: simd_float2(1, 0))
        ]
    }
}
