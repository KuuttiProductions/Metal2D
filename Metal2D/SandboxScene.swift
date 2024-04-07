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
    var wall = Body(name: "Wall")
    var wallR = Body(name: "WallR")
    var camera = Camera(name: "Camera")
    
    var iteration = 0
    
    override init() {
        super.init()
        addChild(node: bg)
        addChild(node: quad1)
        addChild(node: quad2)
        addChild(node: floor)
        addChild(node: wall)
        addChild(node: wallR)
        physWorld.addBody(body: quad1)
        physWorld.addBody(body: quad2)
        physWorld.addBody(body: floor)
        physWorld.addBody(body: wall)
        physWorld.addBody(body: wallR)
        quad1.set(w: simd_float2(1.0, 1.0), m: 1.0)
        quad2.set(w: simd_float2(1.0, 1.0), m: 1.0)
        floor.set(w: simd_float2(10.0, 0.3), m: Float.greatestFiniteMagnitude)
        wall.set(w: simd_float2(0.3, 5.0), m: Float.greatestFiniteMagnitude)
        wallR.set(w: simd_float2(0.3, 5.0), m: Float.greatestFiniteMagnitude)
        quad1.matColor = simd_float4(1, 0, 0, 1)
        quad2.matColor = simd_float4(0, 0, 1, 1)
        floor.matColor = simd_float4(0, 1, 0, 1)
        quad1.position = simd_float2(1.0, 1.0)
        quad2.position = simd_float2(-1.0, 0.0)
        floor.position.y = -2.0
        wall.position = simd_float2(-5, 1)
        wallR.position = simd_float2(5, 1)
        bg.texture = "Dirt"
        quad1.texture = "cobblestone"
        quad2.texture = "pumpkin"
        bg.backgroundScale = 20
        //addBackground(background: bg)
        addChild(node: camera)
        activateCamera(camera: camera)
        camera.orthographicScale = 3.0
        camera.position.y = 1.0
    }
    
    override func tick(deltaTime: Float) {
        time += deltaTime
        physWorld.step(dt: deltaTime)
        if Input.mouseRight {
            camera.position -= Input.getMouseMoveDelta() / 300
        }
        if iteration < 5 {
            let o = Body(name: "object")
            addChild(node: o)
            physWorld.addBody(body: o)
            o.set(w: simd_float2(1.0, 1.0), m: 1)
            o.position.y = Float(iteration)
            o.position.x = Float(iteration) / 5
            o.texture = "brick"
            iteration += 1
        }
        if Input.mouseLeft {
            let o = Body(name: "smol")
            addChild(node: o)
            physWorld.addBody(body: o)
            o.set(w: simd_float2(0.5, 0.5), m: 0.25)
            o.position.y = 2.0
            o.texture = "gty"
        }
    }
}
