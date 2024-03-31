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
}
