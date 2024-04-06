//
//  Arbiter.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd

struct Contact {
    var position: simd_float2 = simd_float2(0, 0)
    var normal: simd_float2 = simd_float2(0, 0)
    var separation: Float = 0.0
    var pn: Float = 0.0 // Accumulated normal impulse
    var pt: Float = 0.0 // Accumulated tangent impulse
    var pnb: Float = 0.0 // Accumulated normal impulse for position bias
    var massNormal: Float = 0.0
    var massTangent: Float = 0.0
    var bias: Float = 0.0
    var feature: FeaturePair = FeaturePair()
    var r1: simd_float2 = simd_float2(0, 0)
    var r2: simd_float2 = simd_float2(0, 0)
}

struct FeaturePair {
    var value: Int!
    struct Edges {
        var inEdge1: Int
        var outEdge1: Int
        var inEdge2: Int
        var outEdge2: Int
    }
    var e: Edges = .init(inEdge1: 0, outEdge1: 0, inEdge2: 0, outEdge2: 0)
}

struct ArbiterKey: Hashable {
    static func == (lhs: ArbiterKey, rhs: ArbiterKey) -> Bool {
        if lhs.bodyA == rhs.bodyA && lhs.bodyB == rhs.bodyB {
            return true
        } else {
            return false
        }
    }
    
    var bodyA: String
    var bodyB: String
    
    init(bodyA: Body, bodyB: Body) {
        self.bodyA = bodyA.uuid
        self.bodyB = bodyB.uuid
    }
}

class Arbiter {
    var bodyA: Body!
    var bodyB: Body!
    
    var contacts: [Contact]
    var numContacts: Int
    var friction: Float
    
    init(bodyA: Body, bodyB: Body) {
        self.bodyA = bodyA
        self.bodyB = bodyB
        
        let collide = collide(contacts: [Contact(), Contact()], bodyA: bodyA, bodyB: bodyB)
        numContacts = collide.num
        contacts = collide.contacts
        
        friction = sqrtf(bodyA.friction * bodyB.friction)
    }
    
    func update(newContacts: [Contact], numNewContacts: Int) {
        
        var mergedContacts: [Contact] = [Contact(), Contact()]
        
        for i in 0..<numNewContacts {
            let cNew: Contact = newContacts[i]
            var k: Int = -1
            
            for j in 0..<numContacts {
                let cOld: Contact = contacts[j]
                if cOld.feature.value == cNew.feature.value {
                    k = j; break
                }
            }
            
            if k > -1 {
                var c: Contact = newContacts[i]
                let cOld: Contact = contacts[k]
                if PhysicsWorld.warmStarting {
                    c.pn = cOld.pn
                    c.pt = cOld.pt
                    c.pnb = cOld.pnb
                } else {
                    c.pn = 0.0
                    c.pt = 0.0
                    c.pnb = 0.0
                }
                mergedContacts[i] = c
            } else {
                mergedContacts[i] = cNew
            }
        }
        
        for i in 0..<numNewContacts {
            self.contacts[i] = mergedContacts[i]
        }
        
        numContacts = numNewContacts
    }
    
    func preStep(invDt: Float) {
        let k_allowedPenetration: Float = 0.01
        let k_biasFactor: Float = PhysicsWorld.positionCorrection ? 0.2 : 0.0
        
        for i in 0..<numContacts {
            var c: Contact = contacts[i]
            
            let r1 = c.position - bodyA.position
            let r2 = c.position - bodyB.position
            
            // Precompute normal mass, tangent mass and bias
            let rn1 = dot(r1, c.normal)
            let rn2 = dot(r2, c.normal)
            var kNormal = bodyA.invMass + bodyB.invMass
            kNormal += bodyA.invMass * (dot(r1, r1) - rn1 * rn1) + bodyB.invMass * (dot(r2, r2) - rn2 * rn2)
            c.massNormal = 1.0 / kNormal
            
            let tangent = simd_float2(c.normal.y, -c.normal.x)
            let rt1 = dot(r1, tangent)
            let rt2 = dot(r2, tangent)
            var kTangent = bodyA.invMass + bodyB.invMass
            kTangent += bodyA.invMass * (dot(r1, r1) - rt1 * rt1) + bodyB.invMass * (dot(r2, r2) - rt2 * rt2)
            c.massTangent = 1.0 / kTangent
            
            c.bias = -k_biasFactor * invDt * min(c.separation + k_allowedPenetration, 0.0)
            contacts[i] = c
            
            if PhysicsWorld.accumulateImpulses {
                let p: simd_float2 = c.pn * c.normal + c.pt * tangent
                
                bodyA.velocity -= bodyA.invMass * p
                bodyA.angularVelocity -= bodyA.invInertia * cross(r1, p)
                
                bodyB.velocity += bodyB.invMass * p
                bodyB.angularVelocity += bodyB.invInertia * cross(r2, p)
            }
        }
    }
    
    func applyImpulse() {
        let b1 = bodyA!
        let b2 = bodyB!
        
        for i in 0..<numContacts {
            var c = contacts[i]
            
            c.r1 = c.position - b1.position
            c.r2 = c.position - b2.position
            
            // Relative velocity at contact point
            var dv: simd_float2 = b2.velocity + cross(b2.angularVelocity, c.r2) - b1.velocity + cross(b1.angularVelocity, c.r1)
            
            //Compute normal impulse
            let vn = dot(dv, c.normal) // alas v_n - velocity along normal
            
            var dPn = c.massNormal * (-vn + c.bias) // alas p_n
            
            if PhysicsWorld.accumulateImpulses {
                // Clamp the accumulated impulse
                let pn0 = c.pn
                c.pn = max(pn0 + dPn, 0.0)
                dPn = c.pn - pn0
            } else {
                dPn = max(dPn, 0.0)
            }
        
            // Apply contact impulse
            let pn = dPn * c.normal // alas P - the impulse
            
            b1.velocity -= b1.invMass * pn
            b1.angularVelocity -= b1.invMass * cross(c.r1, pn)
            
            b2.velocity += b2.invMass * pn
            b2.angularVelocity += b2.invMass * cross(c.r2, pn)
            
            //  Relative velocity at contact (again)
            dv = b2.velocity + cross(b2.angularVelocity, c.r2) - b1.velocity + cross(b1.angularVelocity, c.r1)
            
            let tangent = cross(c.normal, 1.0)
            let vt = dot(dv, tangent)
            var dPt = c.massTangent * -vt
            
            if PhysicsWorld.accumulateImpulses {
                // Compute friction impulse
                let maxPt = friction * c.pn
                
                // Clamp friction
                let pt0 = c.pt
                c.pt = simd_clamp(pt0 + dPt, -maxPt, maxPt)
                dPt = c.pt - pt0
            } else {
                let maxPt = friction * dPn
                dPt = simd_clamp(dPt, -maxPt, maxPt)
            }
            
            let pt = dPt * tangent
            
            b1.velocity -= b1.invMass * pt
            b1.angularVelocity -= b1.invMass * cross(c.r1, pt)
            
            b2.velocity += b2.invMass * pt
            b2.angularVelocity += b2.invMass * cross(c.r2, pt)
            
            contacts[i] = c
        }
    }
}
