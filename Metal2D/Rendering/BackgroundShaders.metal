//
//  BackgroundShaders.metal
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.2.2024.
//

#include <metal_stdlib>
#import "Shared.metal"
using namespace metal;

constexpr sampler samplerBg = sampler(address::repeat);

fragment half4 background_fragment(VertexOut VerOut [[ stage_in ]],
                                   constant float2 &screenSize [[ buffer(1) ]],
                                   constant float &bgSize [[ buffer(2) ]],
                                   constant float2 &offset [[ buffer(3) ]],
                                   constant float3 &tint [[ buffer(4) ]],
                                   texture2d<float> colorTexture [[ texture(0) ]]) {
    
    half4 color = half4(1,1,1,1);
    float2 unitScalar = normalize(screenSize);
    float2 offsetScaled = offset * float2(1.0, -1.0);
    
    if (!is_null_texture(colorTexture)) {
        color = half4(colorTexture.sample(samplerBg, (VerOut.textureCoordinate * unitScalar + offsetScaled * 0.2) * bgSize));
    }
    
    color.rgb *= half3(tint);
    
    return color;
}

