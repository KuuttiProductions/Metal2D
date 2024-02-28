//
//  Renderer.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Renderer: NSObject {
    var screenSizeX: Float!
    var screenSizeY: Float!
    
    var scene: GameScene!
    var defaultRenderPipelineState: MTLRenderPipelineState!
    
    override init() {
        super.init()
        scene = SandboxScene()
        createRenderPipelineState()
    }
    
    func createRenderPipelineState() {
        let library = Core.device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "basic_vertex")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment")
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            defaultRenderPipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        screenSizeX = Float(size.width)
        screenSizeY = Float(size.height)
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        scene.update(deltaTime: 1.0/60.0)
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.setRenderPipelineState(defaultRenderPipelineState)
        scene.render(renderCommandEncoder: renderCommandEncoder!, deltaTime: 1.0/60.0)
        renderCommandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
