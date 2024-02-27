//
//  MetalTypes.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

public protocol sizeable {}

extension sizeable {
    
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static var size: Int {
        return MemoryLayout<Self>.size
    }
    
    static func stride(_ count: Int)-> Int {
        return MemoryLayout<Self>.stride * count
    }
    
    static func size(_ count: Int)-> Int {
        return MemoryLayout<Self>.size * count
    }
}

extension simd_float3: sizeable {}
extension simd_float2: sizeable {}
extension simd_float4: sizeable {}

struct Vertex: sizeable {
    var position: simd_float2
    var textureCoordinate: simd_float2
}