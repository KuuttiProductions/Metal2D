//
//  BasicShaders.metal
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

#include <metal_stdlib>
#import "Shared.metal"
using namespace metal;

vertex VertexOut basic_vertex(constant VertexIn *vertices [[ buffer(0) ]],
                              constant ModelConstant &modelConstant [[ buffer(1) ]],
                              constant float4x4 &viewMatrix [[ buffer(2) ]],
                              constant float4x4 &projectionMatrix [[ buffer(3) ]],
                              uint vertexID [[ vertex_id ]]) {
    
    VertexOut verOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(vertices[vertexID].position, modelConstant.depth, 1.0);
    verOut.position = projectionMatrix * viewMatrix * worldPosition;
    verOut.textureCoordinate = vertices[vertexID].textureCoordinate;
    
    return verOut;
}

constexpr sampler sampler2d = sampler();

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]],
                              constant float4 &matColor [[ buffer(0) ]],
                              texture2d<float> colorTexture [[ texture(0) ]]) {
    
    half4 color = half4(matColor);
    
    if (!is_null_texture(colorTexture)) {
        color = half4(colorTexture.sample(sampler2d, VerOut.textureCoordinate));
    }
    
    return color;
}

vertex VertexOut simple_vertex(constant VertexIn *vertices [[ buffer(0) ]],
                               uint vertexID [[ vertex_id ]]) {
    
    VertexOut verOut;
    verOut.position = float4(vertices[vertexID].position, 0.95, 1.0);
    verOut.textureCoordinate = vertices[vertexID].textureCoordinate;
    
    return verOut;
}
