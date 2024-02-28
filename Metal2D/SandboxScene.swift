//
//  SandboxScene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import Foundation

class SandboxScene: GameScene {
    
    var time: Float = 0.0
    
    var triangle = Node(name: "Triangle", mesh: .Triangle)
    var quad = Node(name: "Quad", mesh: .Quad)
    var camera = Camera(name: "Camera")
    
    override init() {
        super.init()
        addChild(node: triangle)
        addChild(node: quad)
        quad.texture = "TextureGray"
        quad.depth = 600
        addChild(node: camera)
        activateCamera(camera: camera)
    }
    
    override func tick(deltaTime: Float) {
        time += deltaTime
        triangle.position.y = sin(time)
    }
}
