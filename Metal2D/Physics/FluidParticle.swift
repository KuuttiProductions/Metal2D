//
//  FluidParticle.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.3.2024.
//

import simd

class FluidParticle: Node {
    
    let gravity: simd_float2 = simd_float2(0, -9.81)
    let world: FluidWorld
    var velocity: simd_float2 = simd_float2(0, 0)
    var radius: Float = 0.5
    
    init(world: FluidWorld) {
        self.world = world
        super.init(name: "FluidParticle")
        self.mesh = .Circle
        self.matColor = simd_float4(0.1, 0.5, 1.0, 1)
    }
    
    override func tick(deltaTime: Float) {
        self.velocity += gravity * deltaTime
        //self.position += velocity * deltaTime
        
        if abs(self.position.x) > world.sizeX {
            self.position.x = world.sizeX * sign(self.position).x
            self.velocity.x *= -0.9
        }
        if abs(self.position.y) > world.sizeY {
            self.position.y = world.sizeY * sign(self.position).y
            self.velocity.y *= -0.9
        }
    }
    
    func smoothingKernel(position: simd_float2)-> Float{
        let volume = Float.pi * pow(radius, 8) / 4
        let distance = distance(self.position, position)
        
        let value = max(0, radius * radius - distance * distance)
        return value * value * value / volume
    }
}
