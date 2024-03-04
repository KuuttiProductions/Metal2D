//
//  SpeedShader.metal
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.3.2024.
//

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

constexpr sampler sampler2d = sampler(address::repeat);

fragment half4 speed_fragment(VertexIn VerIn [[ stage_in ]],
                              constant float &speed [[ buffer(0) ]],
                              constant float &time [[ buffer(1) ]],
                              texture2d<float> texture [[ texture(0) ]]) {
    
    half4 color = half4();
    float2 coord = (VerIn.textureCoordinate - float2(0, time)) / float2(1, max(speed, 1.0));
    
    color = half4(texture.sample(sampler2d, coord));
    
    return color;
}
