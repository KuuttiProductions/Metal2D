//
//  PhysicsMath.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd

extension simd_float2x2 {
    static func rotation(angle: Float)-> simd_float2x2 {
        var mat = simd_float2x2()
        
        mat.columns = (
            simd_float2(cos(angle), -sin(angle)),
            simd_float2(sin(angle),  cos(angle))
        )
        
        return mat
    }
    
    static func abs(_ mat: simd_float2x2)-> simd_float2x2 {
        var mat = simd_float2x2()
        
        mat.columns = (
            simd_abs(mat.columns.0),
            simd_abs(mat.columns.1)
        )
        
        return mat
    }
}
