//
//  PhysicsMath.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd

func rotation(angle: Float)-> simd_float2x2 {
    var mat = simd_float2x2()
    
    mat.columns = (
        simd_float2(cos(angle), -sin(angle)),
        simd_float2(sin(angle),  cos(angle))
    )
    
    return mat
}

func abs(_ inMat: simd_float2x2)-> simd_float2x2 {
    var mat = simd_float2x2()
    
    mat.columns = (
        simd_abs(inMat.columns.0),
        simd_abs(inMat.columns.1)
    )
    
    return mat
}

func cross(_ a: simd_float2, _ b: simd_float2)-> Float {
    return (a.x * b.y) - (a.y * b.x)
}

func cross(_ a: simd_float2, _ s: Float)-> simd_float2 {
    return simd_float2(s * a.y, -s * a.x);
}

func cross(_ s: Float, _ a: simd_float2)-> simd_float2 {
    return simd_float2(-s * a.y, s * a.x);
}
