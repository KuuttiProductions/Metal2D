//
//  Camera.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

class Camera: Node {
    var viewMatrix: simd_float3x3 {
        var viewMatrix = matrix_identity_float3x3
        viewMatrix.translate(by: -self.position)
        viewMatrix.rotate(angle: -rotation)
        return viewMatrix
    }
    
    override init(name: String) {
        super.init(name: name)
        self.render = false
    }
}
