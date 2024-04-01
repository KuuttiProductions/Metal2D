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
}

struct FeaturePair {
    var value: Int = 0
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
        if lhs.bodyA.name == rhs.bodyA.name && lhs.bodyB.name == rhs.bodyB.name {
            return true
        } else {
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {}
    
    var bodyA: Body
    var bodyB: Body
    
    init(bodyA: Body, bodyB: Body) {
        self.bodyA = bodyA
        self.bodyB = bodyB
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
        
        var mergedContacts: [Contact] = []
        
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
                var c = Contact()
                let cOld = contacts[k]
                if PhysicsWorld.warmStarting {
                    c.pn = cOld.pn
                    c.pt = cOld.pt
                    c.pnb = cOld.pnb
                } else {
                    c.pn = 0.0
                    c.pt = 0.0
                    c.pnb = 0.0
                }
                mergedContacts.append(c)
                
            } else {
                mergedContacts[i] = newContacts[i]
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
            
            contacts[i] = c
            
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

//            if PhysicsWorld.accumulateImpulses {
//                var p: simd_float2 = c.pn * c.normal + c.pt * tangent
//                
//                let cA = simd_float2(cross(r1, p).x, cross(r1, p).y)
//                bodyA.velocity -= bodyA.invMass * p
//                bodyA.angularVelocity -= bodyA.invInertia * cA
//                
//                bodyB.velocity -= bodyB.invMass * p
//                bodyB.angularVelocity -= bodyB.invInertia * cross(r1, p)
//            }
            
            // 2D CROSS PRODUCTS!!
        }
    }
    
    func applyImpulse() {
        
    }
}
