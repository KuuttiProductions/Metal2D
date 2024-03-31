//
//  Collide.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.3.2024.
//

import simd

enum Axis {
    case faceAx
    case faceAy
    case faceBx
    case faceBy
}

enum EdgeNumbers: Int {
    case NO_EDGE = 0
    case EDGE1 = 1
    case EDGE2 = 2
    case EDGE3 = 3
    case EDGE4 = 4
}

struct ClipVertex {
    var v: simd_float2
    var fp: FeaturePair
}

func collide(contacts: [Contact], bodyA: Body, bodyB: Body)-> (Int, [Contact]) {
    
    let halfA = 0.5 * bodyA.width
    let halfB = 0.5 * bodyB.width
    
    let posA = bodyA.position
    let posB = bodyB.position
    
    let rotA = simd_float2x2.rotation(angle: bodyA.rotation)
    let rotB = simd_float2x2.rotation(angle: bodyB.rotation)
    
    let rotAT = rotA.transpose
    let rotBT = rotB.transpose
    
    let dp: simd_float2 = posB - posA
    let dA: simd_float2 = rotAT * dp
    let dB: simd_float2 = rotBT * dp
    
    let c = rotAT * rotB //Transforms anything from B's local space to A's local space
    let absC = simd_float2x2.abs(c)
    let absCT = absC.transpose
    
    // Box A faces
    let faceA = abs(dA) - halfA - absC  * halfB
    if faceA.x > 0.0 || faceA.y > 0.0 {
        return (0, [])
    }
    
    // Box B faces
    let faceB = abs(dB) - absCT * halfA - halfB
    if faceB.x > 0.0 || faceA.y > 0.0 {
        return (0, [])
    }
    
    let relativeTol: Float = 0.95
    let absoluteTol: Float = 0.01
    
    // Retrieve axis, separation and normals from best axis (which one has the smallest separation)
    var axis: Axis = .faceAx
    var separation: Float = faceA.x
    var normal: simd_float2 = dA.x > 0.0 ? rotA.columns.0 : -rotA.columns.0
    
    if faceA.y > relativeTol * separation + absoluteTol * halfA.y {
        axis = .faceAy
        separation = faceA.y
        normal = dA.y > 0.0 ? rotA.columns.1 : -rotA.columns.1
    }
    
    if faceB.x > relativeTol * separation + absoluteTol * halfB.x {
        axis = .faceBx
        separation = faceB.x
        normal = dB.x > 0.0 ? rotB.columns.0 : -rotB.columns.0
    }
    
    if faceB.y > relativeTol * separation + absoluteTol * halfB.y {
        axis = .faceBy
        separation = faceB.y
        normal = dB.y > 0.0 ? rotB.columns.1 : -rotB.columns.1
    }
    
    var frontNormal: simd_float2
    var frontTangent: simd_float2
    var incidentEdge: [ClipVertex]
    var front: Float
    var negSide: Float
    var posSide: Float
    var neqEdge: EdgeNumbers
    var posEdge: EdgeNumbers
    
    switch axis {
    case .faceAx:
        frontNormal = normal
        front = dot(posA, frontNormal) + halfA.x
        frontTangent = rotA.columns.1
        let side: Float = dot(posA, frontTangent)
        negSide = -side + halfA.y
        posSide =  side + halfA.y
        neqEdge = .EDGE3
        posEdge = .EDGE1
        incidentEdge = computeIncidentEdge(half: halfB,
                                           pos: posB, rot: rotB, normal: frontNormal)
    case .faceAy:
        frontNormal = normal
        front = dot(posA, frontNormal) + halfA.y
        frontTangent = rotA.columns.0
        let side: Float = dot(posA, frontTangent)
        negSide = -side + halfA.x
        posSide =  side + halfA.x
        neqEdge = .EDGE2
        posEdge = .EDGE4
        incidentEdge = computeIncidentEdge(half: halfB,
                                           pos: posB, rot: rotB, normal: frontNormal)
    case .faceBx:
        frontNormal = -normal
        front = dot(posB, frontNormal) + halfB.x
        frontTangent = rotB.columns.1
        let side: Float = dot(posB, frontTangent)
        negSide = -side + halfB.y
        posSide =  side + halfB.y
        neqEdge = .EDGE3
        posEdge = .EDGE1
        incidentEdge = computeIncidentEdge(half: halfA,
                                           pos: posA, rot: rotA, normal: frontNormal)
    case .faceBy:
        frontNormal = -normal
        front = dot(posB, frontNormal) + halfB.y
        frontTangent = rotB.columns.0
        let side: Float = dot(posB, frontTangent)
        negSide = -side + halfB.x
        posSide =  side + halfB.x
        neqEdge = .EDGE2
        posEdge = .EDGE4
        incidentEdge = computeIncidentEdge(half: halfA,
                                           pos: posA, rot: rotA, normal: frontNormal)
    }
    
    var clipPoints1: [ClipVertex] = []
    var clipPoints2: [ClipVertex] = []
    var np: Int
    
    var cstl = clipSegmentToLine(vIn: incidentEdge, normal: -frontTangent, offset: negSide, clipEdge: neqEdge.rawValue)
    clipPoints1 = cstl.clip
    np = cstl.val
    
    if np < 2 { return (0, []) }
    
    cstl = clipSegmentToLine(vIn: clipPoints1, normal: frontTangent, offset: posSide, clipEdge: posEdge.rawValue)
    clipPoints2 = cstl.clip
    np = cstl.val
    
    if np < 2 { return (0, []) }
    
    var numContacts = 0
    var contactsOut = contacts
    for i in 0..<2 {
        let separation: Float = dot(frontNormal, clipPoints2[i].v) - front
        
        if separation <= 0.0 {
            contactsOut[numContacts].separation = separation
            contactsOut[numContacts].normal = normal
            contactsOut[numContacts].position = clipPoints2[i].v - separation * frontNormal
            contactsOut[numContacts].feature = clipPoints2[i].fp
            if axis == .faceBx || axis == .faceBy {
                let a = contactsOut[numContacts].feature.e.inEdge2
                let b = contactsOut[numContacts].feature.e.inEdge1
                let c = contactsOut[numContacts].feature.e.outEdge2
                let d = contactsOut[numContacts].feature.e.outEdge1
                contactsOut[numContacts].feature.e = .init(inEdge1: a, outEdge1: b, inEdge2: c, outEdge2: d)
            }
            numContacts += 1
        }
    }
    
    return (numContacts, contactsOut)
}

func clipSegmentToLine(vIn: [ClipVertex], normal: simd_float2, offset: Float, clipEdge: Int)-> 
(val: Int, clip: [ClipVertex]) {
    var clip: [ClipVertex] = []
    var numOut = 0
    
    let distance0 = dot(normal, vIn[0].v) - offset
    let distance1 = dot(normal, vIn[1].v) - offset
    
    if (distance0 <= 0.0) { clip[numOut + 1] = vIn[0]; numOut += 1 }
    if (distance0 <= 0.0) { clip[numOut + 1] = vIn[0]; numOut += 1 }
    
    if (distance0 * distance1 < 0.0) {
        let interp: Float = distance0 / (distance0 - distance1)
        clip[numOut].v = vIn[0].v + interp * (vIn[1].v - vIn[0].v)
        if distance0 > 0.0 {
            clip[numOut].fp = vIn[0].fp
            clip[numOut].fp.e.inEdge1 = clipEdge
            clip[numOut].fp.e.inEdge2 = 0
        } else {
            clip[numOut].fp = vIn[1].fp
            clip[numOut].fp.e.outEdge1 = clipEdge
            clip[numOut].fp.e.outEdge2 = 0
        }
        numOut += 1
    }
    
    return (numOut, clip)
}

func computeIncidentEdge(half: simd_float2,
                         pos: simd_float2,
                         rot: simd_float2x2,
                         normal: simd_float2)-> [ClipVertex] {
    var c: [ClipVertex] = []
    
    let rotT: simd_float2x2 = rot.transpose
    let n = -(rotT * normal)
    let nAbs = abs(n)
    
    if nAbs.x > nAbs.y {
        if sign(n.x) > 0.0 {
            c[0].v = simd_float2(half.x, -half.y)
            c[0].fp.e.inEdge2 = EdgeNumbers.EDGE3.rawValue
            c[0].fp.e.outEdge2 = EdgeNumbers.EDGE4.rawValue
            
            c[1].v = simd_float2(half.x, half.y)
            c[1].fp.e.inEdge2 = EdgeNumbers.EDGE4.rawValue
            c[1].fp.e.outEdge2 = EdgeNumbers.EDGE1.rawValue
        } else {
            c[0].v = simd_float2(-half.x, half.y)
            c[0].fp.e.inEdge2 = EdgeNumbers.EDGE1.rawValue
            c[0].fp.e.outEdge2 = EdgeNumbers.EDGE2.rawValue
            
            c[1].v = simd_float2(-half.x, half.y)
            c[1].fp.e.inEdge2 = EdgeNumbers.EDGE2.rawValue
            c[1].fp.e.outEdge2 = EdgeNumbers.EDGE3.rawValue
        }
    } else {
        if sign(n.y) > 0.0 {
            c[0].v = simd_float2(half.x, half.y)
            c[0].fp.e.inEdge2 = EdgeNumbers.EDGE4.rawValue
            c[0].fp.e.outEdge2 = EdgeNumbers.EDGE1.rawValue
            
            c[1].v = simd_float2(-half.x, half.y)
            c[1].fp.e.inEdge2 = EdgeNumbers.EDGE1.rawValue
            c[1].fp.e.outEdge2 = EdgeNumbers.EDGE2.rawValue
        } else {
            c[0].v = simd_float2(-half.x, -half.y)
            c[0].fp.e.inEdge2 = EdgeNumbers.EDGE2.rawValue
            c[0].fp.e.outEdge2 = EdgeNumbers.EDGE3.rawValue
            
            c[1].v = simd_float2(half.x, -half.y)
            c[1].fp.e.inEdge2 = EdgeNumbers.EDGE3.rawValue
            c[1].fp.e.outEdge2 = EdgeNumbers.EDGE4.rawValue
        }
    }
    
    c[0].v = pos + rot * c[0].v
    c[1].v = pos + rot * c[1].v
    
    return c
}
