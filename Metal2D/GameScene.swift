//
//  Scene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class GameScene {
    
    private var children: [Node] = []
    private var camera: Camera!
    private var background: Background!
    var viewMatrix: simd_float4x4 = matrix_identity_float4x4
    var projectionMatrix: simd_float4x4 = matrix_identity_float4x4
    
    func addChild(node: Node) {
        children.append(node)
    }
    
    func activateCamera(camera: Camera) {
        self.camera = camera
    }
    
    func addBackground(background: Background) {
        self.background = background
    }
    
    func update(deltaTime: Float) {
        tick(deltaTime: deltaTime)
        if self.background != nil {
            self.background.offset = camera.position
        }
        self.viewMatrix = camera.viewMatrix
        self.projectionMatrix = camera.projectionMatrix
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }
    
    func tick(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        renderCommandEncoder.setVertexBytes(&viewMatrix, length: simd_float4x4.stride, index: 2)
        renderCommandEncoder.setVertexBytes(&projectionMatrix, length: simd_float4x4.stride, index: 3)
        for child in children {
            child.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        }
    }
}
