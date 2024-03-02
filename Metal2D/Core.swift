//
//  Core.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Core {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    static func initialize(device: MTLDevice) {
        Core.device = device
        Core.commandQueue = device.makeCommandQueue()
        Core.library  = device.makeDefaultLibrary()
        
        ShaderLibrary.initialize()
        
        RenderPipelineStateLibrary.initialize()
        
        MeshLibrary.initialize()
        TextureLibrary.initialize()
        
        Input.initialize()
    }
}
