//
//  RenderMath.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import simd

extension Float {
    var deg2rad: Float {
        return self / 180 * Float.pi
    }
    
    var rad2deg: Float {
        return self / Float.pi * 180
    }
}

extension matrix_float4x4 {
    
    mutating func translate(by: simd_float2) {
        var result = simd_float4x4()
        
        let x = by.x
        let y = by.y
        
        result.columns = (
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, 0, 1)
        )
        
        self = matrix_multiply(result, self)
    }
    
    mutating func scale(by: simd_float2) {
        var result = simd_float4x4()
        
        let x = by.x
        let y = by.y
        
        result.columns = (
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(0, 0, 0, 1)
        )
        
        self = matrix_multiply(result, self)
    }
    
    mutating func rotate(angle: Float) {
        var result = simd_float4x4()
        
        let r1c1 = cos(angle)
        let r1c2 = -sin(angle)
        let r2c1 = sin(angle)
        let r2c2 = cos(angle)
        
        result.columns = (
            simd_float4(r1c1, r1c2, 0, 0),
            simd_float4(r2c1, r2c2, 0, 0),
            simd_float4(0,    0,    1, 0),
            simd_float4(0,    0,    0, 1)
        )
        
        self = matrix_multiply(result, self)
    }
    
    mutating func orthographic(screenSize: simd_float2, orthographicScale: Float) {
        var result = simd_float4x4()
        
        let n = normalize(screenSize)
        let x = n.x / orthographicScale
        let y = n.y / orthographicScale
        
        result.columns = (
            simd_float4(y, 0, 0, 0),
            simd_float4(0, x, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(0, 0, 0, 1)
        )
        
        self = matrix_multiply(result, self)
    }
}
