//
//  BackgroundTile.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.2.2024.
//

import MetalKit

class Background: Node {
    var backgroundScale: Float = 1.0
    var offset: simd_float2!
    var tint: simd_float3 = simd_float3(1.0, 1.0, 1.0)
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        renderCommandEncoder.pushDebugGroup("Rendering background")
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.getPipelineState(key: .Background))
        renderCommandEncoder.setFragmentBytes(&Renderer.screenSize, length: simd_float2.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&backgroundScale, length: Float.stride, index: 2)
        renderCommandEncoder.setFragmentBytes(&offset, length: simd_float2.stride, index: 3)
        renderCommandEncoder.setFragmentBytes(&tint, length: simd_float3.stride, index: 4)
        renderCommandEncoder.setFragmentTexture(TextureLibrary.getTexture(key: texture), index: 0)
        MeshLibrary.getMesh(key: .Quad).draw(renderCommandEncoder: renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
}
