//
//  FluidParticle.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.3.2024.
//

import simd

class FluidParticle: Node {
    

    
    init(world: FluidWorld) {
        self.world = world
        super.init(name: "FluidParticle")
        self.mesh = .Circle
        self.matColor = simd_float4(0.1, 0.5, 1.0, 1)
    }
    
    override func tick(deltaTime: Float) {

    }
    

}
