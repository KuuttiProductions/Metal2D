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
    
    let gravity: simd_float2 = simd_float2(0, -9.81)
    var radius: Float = 0.3
    
    var idealDensity: Float = 120
    var pressureMultiplier: Float = 100000
    
    var velocities: [simd_float2] = []
    var positions: [simd_float2] = []
    var densities: [Float] = []
    var particleProperties: [Float] = []
    var modelConstants: [ModelConstant] = []
    var modelConstantBuffer: MTLBuffer!
    
    let particleMass: Float = 1.0
    var particleColor: simd_float4 = simd_float4(0.0, 0.5, 1.0, 1.0)
    let particleScale: simd_float2 = simd_float2(0.05, 0.05)
    
    var picker: Node!
    
    init(numParticles: Int, bounds: simd_float2) {
        super.init(name: "FluidWorld", mesh: .Quad)
        self.matColor = simd_float4(0, 0, 0, 0)
        sizeX = bounds.x
        sizeY = bounds.y
        self.scale = bounds
        
        for _ in 0..<numParticles {
            let positionX = Float.random(in: -sizeX...sizeX)
            let positionY = Float.random(in: -sizeY...sizeY)
            let position = simd_float2(positionX, positionY)
            positions.append(position)
            velocities.append(simd_float2(0, 0))
            densities.append(0)
        }
        
        modelConstantBuffer = Core.device.makeBuffer(length: ModelConstant.stride(positions.count))
        modelConstantBuffer.label = "Particle modelConstants"
    }
    
    override func tick(deltaTime: Float) {
        for (i, x) in positions.enumerated() {
            velocities[i] += gravity * deltaTime
            densities[i] = calculateDensity(samplePoint: x)
        }
        
        for (i, _) in positions.enumerated() {
            let pressureForce = calculatePressureForce(particleIndex: i)
            let pressureAcceleration = pressureForce / densities[i]
            velocities[i] = pressureAcceleration * deltaTime
        }
        
        for (i, x) in positions.enumerated() {
            var velocity = velocities[i]
            var position = x + velocity * deltaTime
            
            if abs(position.x) > sizeX {
                position.x = sizeX * sign(position).x
                velocity.x *= -0.9
            }
            if abs(position.y) > sizeY {
                position.y = sizeY * sign(position).y
                velocity.y *= -0.9
            }
            velocities[i] = velocity
            positions[i] = position
        }
        SwiftUIInterface.shared.density = calculateDensity(samplePoint: picker.position)
        updateModelConstantBuffer()
        picker.scale = simd_float2(radius, radius)
    }
    
    func sharedPressure(particleDensityA: Float, particleDensityB: Float)-> Float {
        let densityA = convertDensityToPressure(density: particleDensityA)
        let densityB = convertDensityToPressure(density: particleDensityB)
        return (densityA + densityB) / 2
    }

    func convertDensityToPressure(density: Float)-> Float {
        let pressureError = density - idealDensity
        return pressureError * pressureMultiplier
    }
    
    func smoothingKernel(distance: Float)-> Float{
        let volume = Float.pi * pow(radius, 4) / 6
        return (radius - distance) * (radius - distance) / volume
    }
    
    func smoothingKernelDerivate(distance: Float)-> Float {
        if (distance >= radius) { return 0.0 }
        let scale = 12 / (Float.pi * pow(radius, 4))
        return (distance - radius) * scale
    }
    
    func calculateDensity(samplePoint: simd_float2)-> Float {
        var density: Float = 0.0
        
        for position in positions {
            let distance = distance(position, samplePoint)
            density += particleMass * smoothingKernel(distance: distance)
        }
        
        return density
    }
    
    func calculatePressureForce(particleIndex: Int)-> simd_float2 {
        var pressureForce: simd_float2 = simd_float2()
        
        for (i, x) in positions.enumerated() {
            if i == particleIndex { continue }
            let distance = max(distance(x, positions[particleIndex]), 0.001)
            let direction = (x - positions[particleIndex]) / distance
            let slope = smoothingKernelDerivate(distance: distance)
            let density = densities[i]
            let sharedPressure = sharedPressure(particleDensityA: density, particleDensityB: densities[particleIndex])
            pressureForce += sharedPressure * direction * slope * particleMass / density
        }
        
        return pressureForce
    }
    
    func updateModelConstantBuffer() {
        var pointer = modelConstantBuffer.contents().bindMemory(to: ModelConstant.self, capacity: ModelConstant.stride(positions.count))
        for position in positions {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(by: position)
            modelMatrix.scale(by: particleScale)
            pointer.pointee.modelMatrix = modelMatrix
            pointer.pointee.depth = simd_clamp(Float(depth - 1) / 1000, 0.0, 1.0) * 0.9
            pointer = pointer.advanced(by: 1)
        }
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        super.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        renderCommandEncoder.pushDebugGroup("Rendering fluid particles")
        renderCommandEncoder.setVertexBuffer(modelConstantBuffer, offset: 0, index: 1)
        renderCommandEncoder.setFragmentBytes(&particleColor, length: simd_float4.stride, index: 0)
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.getPipelineState(key: .Instanced))
        MeshLibrary.getMesh(key: .Circle).draw(renderCommandEncoder: renderCommandEncoder, instanceCount: positions.count)
        renderCommandEncoder.popDebugGroup()
    }
}
