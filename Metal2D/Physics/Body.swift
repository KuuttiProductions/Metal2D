//
//  Body.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 29.3.2024.
//

import simd
import Foundation

class Body: Node {
    var width = simd_float2(1, 1)
    var force = simd_float2(0, 0)
    var torque: Float = 0.0
    
    var velocity: simd_float2 = simd_float2(0, 0)
    var angularVelocity: Float = 0.0
    
    func addForce(f: simd_float2) {
        force += f
    }
    
    var friction: Float = 0.2
    var mass: Float = Float.greatestFiniteMagnitude
    var invMass: Float = 0.0
    var inertia: Float = Float.greatestFiniteMagnitude
    var invInertia: Float = 0.0
    
    func set(w: simd_float2, m: Float) {
        width = w
        mass = m
        
        if mass < Float.greatestFiniteMagnitude {
            invMass = 1.0 / mass
            inertia = mass * (width.x * width.x + width.y * width.y) / 12.0
            invInertia = 1.0 / inertia
        } else {
            invMass = 0.0
            inertia = Float.greatestFiniteMagnitude
            invInertia = 0.0
        }
    }
}
