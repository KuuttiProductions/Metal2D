//
//  Shared.metal
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.2.2024.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position;
    float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[ position, invariant ]];
    float2 textureCoordinate;
};

struct ModelConstant {
    float4x4 modelMatrix;
    float depth;
};
