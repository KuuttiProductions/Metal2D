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
    
    let gravity: simd_float2 = simd_float2(0, -0.2)
    var radius: Float = 0.2
    
    var idealDensity: Float = 10
    var pressureMultiplier: Float = 3
    
    var worldQuads: [FluidWorldQuad] = []
    
    var velocities: [simd_float2] = []
    var positions: [simd_float2] = []
    var predictedPositions: [simd_float2] = []
    var densities: [Float] = []
    var particleProperties: [Float] = []
    
    var modelConstants: [ModelConstant] = []
    var modelConstantBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    
    let particleMass: Float = 1.0
    var particleColor: simd_float4 = simd_float4(0, 0, 0, 0)
    let particleScale: simd_float2 = simd_float2(0.03, 0.03)
    
    var picker: Node!
    
    init(numParticles: Int, bounds: simd_float2) {
        super.init(name: "FluidWorld", mesh: .Quad)
        self.matColor = simd_float4(0, 0, 0, 0)
        sizeX = bounds.x
        sizeY = bounds.y
        self.scale = bounds
        
        for x in 0...Int(bounds.x / radius) {
            for y in 0...Int(bounds.y / radius) {
                let halfX = bounds.x / 2
                let halfY = bounds.y / 2
                let pos = simd_float2((Float(x)*radius-halfX)*2,
                                      (Float(y)*radius-halfY)*2)
                worldQuads.append(FluidWorldQuad(pos: pos))
            }
        }
        
        for x in 0..<20 {
            for y in 0..<20 {
                let positionX: Float = Float(x) / 10.0 - bounds.x / 2
                let positionY: Float = Float(y) / 10.0 - bounds.y / 2
                let position = simd_float2(positionX, positionY)
                positions.append(position)
                predictedPositions.append(simd_float2(0, 0))
                velocities.append(simd_float2(0, 0))
                densities.append(0)
            }
        }
        updateQuads()
        
        modelConstantBuffer = Core.device.makeBuffer(length: ModelConstant.stride(positions.count))
        modelConstantBuffer.label = "Particle modelConstants"
        colorBuffer = Core.device.makeBuffer(length: ModelConstant.stride(positions.count))
        colorBuffer.label = "Particle colors"
    }
    
    override func tick(deltaTime: Float) {
        for (i, x) in positions.enumerated() {
            predictedPositions[i] = positions[i] + velocities[i] * 1 / 60
            velocities[i] += gravity * deltaTime
            densities[i] = calculateDensity(samplePoint: x)
        }
        
        for (i, x) in positions.enumerated() {
            let pressureForce = calculatePressureForce(particleIndex: i, particlePos: x)
            let pressureAcceleration = pressureForce / densities[i]
            velocities[i] += pressureAcceleration * deltaTime
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
        updateBuffers()
        picker.scale = simd_float2(radius, radius)
        updateQuads()
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
        
        let particlesQuery = queryParticles(position: samplePoint)
        
        for i in particlesQuery {
            let distance = distance(predictedPositions[i], samplePoint)
            density += particleMass * smoothingKernel(distance: distance)
        }
        
        return density
    }
    
    func calculatePressureForce(particleIndex: Int, particlePos: simd_float2)-> simd_float2 {
        var pressureForce: simd_float2 = simd_float2()
        
        let particlesQuery = queryParticles(position: particlePos)
        
        for i in particlesQuery {
            if i == particleIndex { continue }
            let distance = max(distance(positions[i], predictedPositions[particleIndex]), 0.001)
            let direction = (predictedPositions[i] - predictedPositions[particleIndex]) / distance
            let slope = smoothingKernelDerivate(distance: distance)
            let density = densities[i]
            let sharedPressure = sharedPressure(particleDensityA: density, particleDensityB: densities[particleIndex])
            pressureForce += sharedPressure * direction * slope * particleMass / density
        }
        
        return pressureForce
    }
    
    func queryParticles(position: simd_float2)-> [Int] {
        var particles: [Int] = []
        for quad in worldQuads {
            if abs(quad.position.x - position.x) > radius + 0.1 { continue }
            if abs(quad.position.y - position.y) > radius + 0.1 { continue }
            particles.append(contentsOf: quad.particles)
        }
        
        return particles
    }
    
    func updateQuads() {
        for quad in worldQuads {
            quad.particles = []
        }
        for (i, x) in positions.enumerated() {
            for quad in worldQuads {
                if abs(quad.position.x - x.x) < radius {
                    if abs(quad.position.y - x.y) < radius {
                        quad.particles.append(i)
                        break
                    }
                }
            }
        }
    }
    
    func updateBuffers() {
        var pointer = modelConstantBuffer.contents().bindMemory(to: ModelConstant.self, capacity: ModelConstant.stride(positions.count))
        for position in positions {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(by: position)
            modelMatrix.scale(by: particleScale)
            pointer.pointee.modelMatrix = modelMatrix
            pointer.pointee.depth = simd_clamp(Float(depth - 1) / 1000, 0.0, 1.0) * 0.9
            pointer = pointer.advanced(by: 1)
        }
        var colPointer = colorBuffer.contents().bindMemory(to: simd_float4.self, capacity: simd_float4.stride(positions.count))
        for velocity in velocities {
            let speed = min(max(length(velocity), 0.0), 3.0) / 3
            colPointer.pointee = simd_float4(speed, 1-speed, 0, 1.0)
            colPointer = colPointer.advanced(by: 1)
        }
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        super.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        renderCommandEncoder.pushDebugGroup("Rendering fluid particles")
        renderCommandEncoder.setVertexBuffer(modelConstantBuffer, offset: 0, index: 1)
        renderCommandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 4)
        renderCommandEncoder.setFragmentBytes(&particleColor, length: simd_float4.stride, index: 0)
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStateLibrary.getPipelineState(key: .Instanced))
        MeshLibrary.getMesh(key: .Circle).draw(renderCommandEncoder: renderCommandEncoder, instanceCount: positions.count)
        renderCommandEncoder.popDebugGroup()
    }
}

class FluidWorldQuad {
    var position: simd_float2
    var particles: [Int] = []
    
    init(pos: simd_float2) {
        position = pos
    }
}
