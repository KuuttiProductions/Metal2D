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
    var viewMatrix: simd_float3x3 = matrix_identity_float3x3
    
    func addChild(node: Node) {
        children.append(node)
    }
    
    func activateCamera(camera: Camera) {
        self.camera = camera
    }
    
    func update(deltaTime: Float) {
        tick(deltaTime: deltaTime)
        self.viewMatrix = camera.viewMatrix
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }
    
    func tick(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        renderCommandEncoder.setVertexBytes(&viewMatrix, length: simd_float3x3.stride, index: 2)
        for child in children {
            child.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        }
    }
}
