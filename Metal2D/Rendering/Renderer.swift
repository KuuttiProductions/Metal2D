//
//  Renderer.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Renderer: NSObject {
    static var screenSize: simd_float2!
    
    var scene: GameScene!
    var depthStencilState: MTLDepthStencilState!
    
    override init() {
        super.init()
        scene = SandboxScene()
        createDepthStencilState()
    }
    
    func createDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = Core.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Renderer.screenSize = simd_float2(Float(size.width), Float(size.height))
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        scene.update(deltaTime: 1.0/60.0)
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.setDepthStencilState(depthStencilState)
        scene.render(renderCommandEncoder: renderCommandEncoder!, deltaTime: 1.0/60.0)
        renderCommandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
