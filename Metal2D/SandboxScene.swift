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
    var physWorld = PhysicsWorld()
    var quad1 = Body(name: "Quad1")
    var quad2 = Body(name: "Quad2")
    var floor = Body(name: "Floor")
    var camera = Camera(name: "Camera")
    
    override init() {
        super.init()
        addChild(node: bg)
        addChild(node: quad1)
        addChild(node: quad2)
        addChild(node: floor)
        physWorld.addBody(body: quad1)
        physWorld.addBody(body: quad2)
        physWorld.addBody(body: floor)
        quad1.set(w: simd_float2(1.0, 1.0), m: 1.0)
        quad2.set(w: simd_float2(1.0, 1.0), m: 1.0)
        floor.set(w: simd_float2(10.0, 0.3), m: Float.greatestFiniteMagnitude)
        floor.scale = simd_float2(10, 0.3)
        quad1.position.y = 2.5
        floor.position.y = -2.0
        bg.texture = "BackgroundTexture2"
        bg.backgroundScale = 3.0
        bg.tint = simd_float3(0.1, 0.3, 1)
        //addBackground(background: bg)
        addChild(node: camera)
        activateCamera(camera: camera)
        camera.orthographicScale = 3.0
    }
    
    override func tick(deltaTime: Float) {
        time += deltaTime
        physWorld.step(dt: deltaTime)
        if Input.mouseRight {
            camera.position -= Input.getMouseMoveDelta() / 500
        }
    }
}
