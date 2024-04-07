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
    var gravity = simd_float2(0, -3.0)
    
    var iterations: Int = 20
    static var accumulateImpulses: Bool = false
    static var warmStarting: Bool = true
    static var positionCorrection: Bool = true
    
    func addBody(body: Body) {
        self.bodies.append(body)
    }
    
    func broadPhase() {
        
        // O(n^2) Broad-phase. AABB implementation would be advantageous!
        for i in 0..<bodies.count {
            let ba = bodies[i]
            
            for x in i+1..<bodies.count {
                let bb = bodies[x]
                
                let newArb = Arbiter(bodyA: ba, bodyB: bb)
                let key = ArbiterKey(bodyA: ba, bodyB: bb)
                
                if newArb.numContacts > 0 {
                    if let iter = arbiters[key] {
                        iter.update(newContacts: newArb.contacts, numNewContacts: newArb.numContacts)
                    } else {
                        arbiters[key] = newArb
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
        
        // Pre-steps
        for arb in arbiters {
            arb.value.preStep(invDt: inv_dt)
        }
        
        //Perform iterations
        for _ in 0..<iterations {
            for arb in arbiters {
                arb.value.applyImpulse()
            }
        }
        
        //Integrate velocities
        for b in bodies {
            b.position += dt * b.velocity
            b.rotation -= dt * b.angularVelocity
            
            b.force = simd_float2(0, 0)
            b.torque = 0.0
        }
    }
}
