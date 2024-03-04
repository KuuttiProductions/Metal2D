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

class CircleMesh: Mesh {
    override func addVertices() {
        let vertexCount: Int = 32
        let angle: Float = 2 * Float.pi / Float(vertexCount)
        let a: simd_float2 = simd_float2(0.0, 0.0)

        var last: simd_float2 = simd_float2(1.0, 0.0)
        for _ in 0..<vertexCount {
            let b = last
            var c = last
            let x = c.x * cos(angle) - c.y * sin(angle)
            let y = c.x * sin(angle) + c.y * cos(angle)
            c = normalize(simd_float2(x, y))
            self.vertices.append(Vertex(position: a, textureCoordinate: simd_float2(0,0)))
            self.vertices.append(Vertex(position: b, textureCoordinate: simd_float2(0,0)))
            self.vertices.append(Vertex(position: c, textureCoordinate: simd_float2(0,0)))
            last = c
        }
    }
}
