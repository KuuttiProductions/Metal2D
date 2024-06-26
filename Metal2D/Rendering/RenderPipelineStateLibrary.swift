//
//  RenderPipelineStateLibrary.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.2.2024.
//

import MetalKit

enum RenderPipelineStateType {
    case Basic
    case Background
    case Speed
    case Instanced
}

class RenderPipelineStateLibrary {
    
    private static var pipelineStates: [RenderPipelineStateType : RenderPipelineState] = [:]

    static func initialize() {
        RenderPipelineStateLibrary.pipelineStates.updateValue(BasicRenderPipelineState(), forKey: .Basic)
        RenderPipelineStateLibrary.pipelineStates.updateValue(BackgroundRenderPipelineState(), forKey: .Background)
        RenderPipelineStateLibrary.pipelineStates.updateValue(SpeedRenderPipelineState(), forKey: .Speed)
        RenderPipelineStateLibrary.pipelineStates.updateValue(InstancedRenderPipelineState(), forKey: .Instanced)
    }
    
    static func getPipelineState(key: RenderPipelineStateType)-> MTLRenderPipelineState {
        return RenderPipelineStateLibrary.pipelineStates[key]!.pipelineState
    }
}

class RenderPipelineState {
    var pipelineState: MTLRenderPipelineState!
    var descriptor: MTLRenderPipelineDescriptor!
    init() {
        descriptor = MTLRenderPipelineDescriptor()
    }
}

class BasicRenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        descriptor.vertexFunction = ShaderLibrary.getShader(key: .Basic_vertex)
        descriptor.fragmentFunction = ShaderLibrary.getShader(key: .Basic_fragment)
        descriptor.depthAttachmentPixelFormat = .depth16Unorm
        do {
            pipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
    }
}

class InstancedRenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        descriptor.vertexFunction = ShaderLibrary.getShader(key: .Instanced_vertex)
        descriptor.fragmentFunction = ShaderLibrary.getShader(key: .Basic_fragment)
        descriptor.depthAttachmentPixelFormat = .depth16Unorm
        do {
            pipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
    }
}

class BackgroundRenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        descriptor.vertexFunction = ShaderLibrary.getShader(key: .Simple_vertex)
        descriptor.fragmentFunction = ShaderLibrary.getShader(key: .Background_fragment)
        descriptor.depthAttachmentPixelFormat = .depth16Unorm
        do {
            pipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
    }
}

class SpeedRenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        descriptor.vertexFunction = ShaderLibrary.getShader(key: .Simple_vertex)
        descriptor.fragmentFunction = ShaderLibrary.getShader(key: .Speed_fragment)
        descriptor.depthAttachmentPixelFormat = .depth16Unorm
        do {
            pipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
    }
}
