//
//  ShaderLibrary.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.2.2024.
//

import MetalKit

enum ShaderType {
    case Basic_vertex
    case Simple_vertex
    case Basic_fragment
    case Background_fragment
    case Speed_fragment
}

class ShaderLibrary {
    private static var shaders: [ShaderType : Shader] = [:]
    
    static func initialize() {
        ShaderLibrary.shaders.updateValue(Shader(name: "basic_vertex"), forKey: .Basic_vertex)
        ShaderLibrary.shaders.updateValue(Shader(name: "basic_fragment"), forKey: .Basic_fragment)
        ShaderLibrary.shaders.updateValue(Shader(name: "simple_vertex"), forKey: .Simple_vertex)
        ShaderLibrary.shaders.updateValue(Shader(name: "background_fragment"), forKey: .Background_fragment)
        ShaderLibrary.shaders.updateValue(Shader(name: "speed_fragment"), forKey: .Speed_fragment)
    }
    
    static func getShader(key: ShaderType)-> MTLFunction {
        return ShaderLibrary.shaders[key]!.shader
    }
}

class Shader {
    var shader: MTLFunction!
    init(name: String) {
        shader = Core.library.makeFunction(name: name)
    }
}
