//
//  FluidWorld.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.3.2024.
//

import simd
import MetalKit

class FluidWorld: Node {
    var sizeX: Float = 2.0
    var sizeY: Float = 2.0
    
    var particles: [FluidParticle] = []
    var picker: Node!
    
    init(numParticles: Int, bounds: simd_float2) {
        super.init(name: "FluidWorld", mesh: .Quad)
        self.matColor = simd_float4(0, 0, 0, 0)
        sizeX = bounds.x
        sizeY = bounds.y
        self.scale = bounds
        
        for _ in 0..<numParticles {
            let particle = FluidParticle(world: self)
            particle.scale = simd_float2(0.05, 0.05)
            particle.position.x = Float.random(in: -sizeX...sizeX)
            particle.position.y = Float.random(in: -sizeY...sizeY)
            particle.depth = self.depth - 1
            particles.append(particle)
        }
    }
    
    override func tick(deltaTime: Float) {
        for particle in particles {
            particle.update(deltaTime: deltaTime)
        }
        SwiftUIInterface.shared.density = calculateDensity(samplePoint: picker.position)
    }
    
    func calculateDensity(samplePoint: simd_float2)-> Float {
        var density: Float = 0.0
        let mass: Float = 1.0
        
        for particle in particles {
            density += mass * particle.smoothingKernel(position: samplePoint)
        }
        
        return density
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        super.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        for particle in particles {
            particle.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        }
    }
}
