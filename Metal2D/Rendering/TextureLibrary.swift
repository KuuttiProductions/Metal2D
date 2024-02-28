//
//  TextureLibrary.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

class TextureLibrary {
    
    static var textures: [String : Texture] = [:]
    
    static func initialize() {
        TextureLibrary.textures.updateValue(Texture("TextureOrange"), forKey: "TextureOrange")
        TextureLibrary.textures.updateValue(Texture("TextureGray"), forKey: "TextureGray")
    }
    
    static func getTexture(key: String)-> MTLTexture {
        return TextureLibrary.textures[key]!.texture
    }
    
}

class Texture {
    var texture: MTLTexture
    
    init(_ name: String) {
        let url = Bundle.main.url(forResource: name, withExtension: "png")
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: Core.device)
        
        texture = try! textureLoader.newTexture(URL: url!)
    }
}
