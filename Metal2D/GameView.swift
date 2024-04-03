//
//  GameView.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import SwiftUI
import MetalKit

struct GameView: NSViewRepresentable {
    class InputView: MTKView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {}
        override func keyUp(with event: NSEvent) {}
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.delegate?.mtkView(nsView, drawableSizeWillChange: nsView.drawableSize)
    }
    
    func makeCoordinator() -> Renderer {
        return Renderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView: MTKView = InputView()
        
        mtkView.device = Core.device
        mtkView.clearColor = MTLClearColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        mtkView.delegate = context.coordinator
        mtkView.depthStencilPixelFormat = .depth16Unorm
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        
        return mtkView
    }
}
