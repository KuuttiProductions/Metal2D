//
//  Arbiter.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd

struct Contact {
    var position: simd_float2 = simd_float2(0, 0)
    var normal: simd_float2 = simd_float2(0, 0)
    var separation: Float = 0.0
    var pn: Float = 0.0 // Accumulated normal impulse
    var pt: Float = 0.0 // Accumulated tangent impulse
    var pnb: Float = 0.0 // Accumulated normal impulse for position bias
    var massNormal: Float = 0.0
    var massTangent: Float = 0.0
    var bias: Float = 0.0
    var feature: FeaturePair
}

struct FeaturePair {
    var value: Int
    struct Edges {
        var inEdge1: Int
        var outEdge1: Int
        var inEdge2: Int
        var outEdge2: Int
    }
    var e: Edges
}
