//
//  Camera.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

class Camera: Node {
    var orthographicScale: Float = 1.0
    
    var viewMatrix: simd_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.translate(by: -self.position)
        viewMatrix.rotate(angle: -rotation)
        return viewMatrix
    }
    
    var projectionMatrix: simd_float4x4 {
        var projectionMatrix = matrix_identity_float4x4
        projectionMatrix.orthographic(screenSize: Renderer.screenSize, orthographicScale: orthographicScale)
        return projectionMatrix
    }
    
    init(name: String) {
        super.init(name: name)
        render = false
    }
}
