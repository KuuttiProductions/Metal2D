//
//  BasicShaders.metal
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
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

vertex VertexOut basic_vertex(constant VertexIn *vertices [[ buffer(0) ]],
                           uint vertexID [[ vertex_id ]]) {
    
    VertexOut verOut;
    verOut.position = float4(vertices[vertexID].position, 0, 1);
    verOut.textureCoordinate = vertices[vertexID].textureCoordinate;
    
    return verOut;
}

constexpr sampler sampler2d = sampler();

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]],
                              texture2d<float> colorTexture [[ texture(0) ]]) {
    
    half4 color = half4(1,1,1,1);
    
    if (!is_null_texture(colorTexture)) {
        color = half4(colorTexture.sample(sampler2d, VerOut.textureCoordinate));
    }
    
    return color;
}
