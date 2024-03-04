//
//  SandboxScene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import simd

class SandboxScene: GameScene {
    
    var time: Float = 0.0

    var bg = Background(name: "Background", mesh: .Quad)
    var picker = Node(name: "Picker", mesh: .Circle)
    var camera = Camera(name: "Camera")
    var fluidSim = FluidWorld(numParticles: 64, bounds: simd_float2(2.0, 2.0))
    
    override init() {
        super.init()
        addChild(node: bg)
        addChild(node: fluidSim)
        addChild(node: picker)
        picker.scale = simd_float2(0.5, 0.5)
        fluidSim.depth = 600
        fluidSim.picker = picker
        bg.texture = "BackgroundTexture2"
        bg.backgroundScale = 2.0
        bg.tint = simd_float3(0.1, 0.3, 1)
        addBackground(background: bg)
        addChild(node: camera)
        activateCamera(camera: camera)
        camera.orthographicScale = 2.0
    }
    
    override func tick(deltaTime: Float) {
        time += deltaTime
        if Input.mouseRight {
            camera.position -= Input.getMouseMoveDelta() / 700
        }
        if Input.mouseLeft {
            picker.position += Input.getMouseMoveDelta() / 500
        }
    }
}
