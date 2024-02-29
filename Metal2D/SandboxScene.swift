//
//  SandboxScene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import simd

class SandboxScene: GameScene {
    
    var time: Float = 0.0
    
    var triangle = Node(name: "Triangle", mesh: .Triangle)
    var quad = Node(name: "Quad", mesh: .Quad)
    var bg = Background(name: "Background", mesh: .Quad)
    var camera = Camera(name: "Camera")
    
    override init() {
        super.init()
        for i in 0..<10 {
            let child = Node(name: "x\(i)", mesh: .Triangle)
            addChild(node: child)
            child.position.x = Float(i * 3)
            child.scale = simd_float2(0.5, 0.5)
        }
        addChild(node: triangle)
        addChild(node: quad)
        addChild(node: bg)
        triangle.scale = simd_float2(0.5, 0.5)
        quad.texture = "TextureGray"
        quad.depth = 600
        quad.scale = simd_float2(0.5, 0.5)
        bg.texture = "BackgroundTexture1"
        bg.backgroundScale = 2.0
        bg.tint = simd_float3(0.1, 0.3, 1)
        addBackground(background: bg)
        addChild(node: camera)
        activateCamera(camera: camera)
    }
    
    override func tick(deltaTime: Float) {
        time += deltaTime
        camera.position.x += deltaTime / 2
        camera.position.y = sin(time) / 2
    }
}
