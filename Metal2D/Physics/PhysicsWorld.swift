//
//  Width.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd

class PhysicsWorld {
    
    var bodies: [Body] = []
    var arbiters: [ArbiterKey : Arbiter] = [:]
    var gravity = simd_float2(0, -9.81)
    
    var iterations: Int = 1
    static var accumulateImpulses: Bool = false
    static var warmStarting: Bool = false
    static var positionCorrection: Bool = false
    
    func addBody(body: Body) {
        self.bodies.append(body)
    }
    
    func broadPhase() {
        // O(n^2) Broadphase. AABB implementation would be advantageous!
        for (i, ba) in bodies.enumerated() {
            for x in i+1..<bodies.count {
                let bb = bodies[x]
                
                if ba.invMass == 0.0 || bb.invMass == 0.0 { continue }
                
                let newArb = Arbiter(bodyA: ba, bodyB: bb)
                let key = ArbiterKey(bodyA: ba, bodyB: bb)
                
                if newArb.numContacts > 0 {
                    if arbiters[key] == nil {
                        let iter = arbiters[key]
                        arbiters.updateValue(newArb, forKey: key)
                    } else {
                        
                    }
                } else {
                    arbiters.removeValue(forKey: key)
                }
            }
        }
    }
    
    func step(dt: Float) {
        
        let inv_dt: Float = dt > 0 ? 1.0 / dt : 0.0
        
        broadPhase()
        
        // Integrate forces
        for b in bodies {
            if b.invMass == 0.0 {
                continue
            }
            
            b.velocity += dt * (gravity + b.invMass * b.force)
            b.angularVelocity += dt * b.invInertia * b.torque
        }
        
        //Integrate velocities
        for b in bodies {
            b.position += dt * b.velocity
            b.rotation += dt * b.angularVelocity
            
            b.force = simd_float2(0, 0)
            b.torque = 0.0
        }
    }
}
