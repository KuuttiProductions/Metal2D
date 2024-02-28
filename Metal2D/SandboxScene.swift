//
//  SandboxScene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import Foundation

class SandboxScene: GameScene {
    
    var time: Float = 0.0
    
    var triangle = Node(name: "Triangle")
    var camera = Camera(name: "Camera")
    
    override init() {
        super.init()
        addChild(node: triangle)
        addChild(node: camera)
        activateCamera(camera: camera)
    }
}
