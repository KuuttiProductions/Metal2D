//
//  TextureLibrary.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

class TextureLibrary {
    
    private static var textures: [String : Texture] = [:]
    
    static func initialize() {
        loadTexture("TextureOrange")
        loadTexture("TextureGray")
        loadTexture("BackgroundTexture1")
        loadTexture("BackgroundTexture2")
        loadTexture("SpeedTexture")
    }
    
    static func getTexture(key: String!)-> MTLTexture! {
        if key == nil { return nil }
        return TextureLibrary.textures[key]!.texture
    }
    
    static func loadTexture(_ name: String) {
        TextureLibrary.textures.updateValue(Texture(name), forKey: name)
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
