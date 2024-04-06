//
//  Debug.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.4.2024.
//

import MetalKit

class Debug {
    static var positions: [simd_float2] = []
    static var normals: [simd_float2] = []
    static var scale: simd_float2 = simd_float2(0.05, 0.05)
    static var matColorPoint = simd_float4(1, 0, 0, 1)
    static var matColorLine = simd_float4(0, 1, 0, 1)
    
    static func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.getPipelineState(key: .Basic))
        for (n, position) in positions.enumerated() {
            renderCommandEncoder.setTriangleFillMode(.fill)
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(by: position)
            modelMatrix.scale(by: scale)
            var m = ModelConstant()
            m.modelMatrix = modelMatrix
            renderCommandEncoder.setVertexBytes(&m, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&matColorPoint, length: simd_float4.stride, index: 0)
            MeshLibrary.getMesh(key: .Circle).draw(renderCommandEncoder: renderCommandEncoder)
            
            renderCommandEncoder.setTriangleFillMode(.lines)
            var vertices = [Vertex(position: simd_float2(0, 0), textureCoordinate: simd_float2(0, 0)),
                            Vertex(position: normals[n] * 10, textureCoordinate: simd_float2(0, 0))]
            renderCommandEncoder.setVertexBytes(&vertices, length: Vertex.stride(2), index: 0)
            renderCommandEncoder.setVertexBytes(&m, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&matColorLine, length: simd_float4.stride, index: 0)
            renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 2)
        }
        positions.removeAll()
        normals.removeAll()
    }
}
