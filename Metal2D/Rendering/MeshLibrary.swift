//
//  MeshLibrary.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 28.2.2024.
//

import MetalKit

enum MeshType {
    case Triangle
    case Quad
}

class MeshLibrary {
    
    static var meshes: [MeshType : Mesh] = [:]
    
    static func initialize() {
        MeshLibrary.meshes.updateValue(TriangleMesh(), forKey: .Triangle)
        MeshLibrary.meshes.updateValue(QuadMesh(), forKey: .Quad)
    }
    
    static func getMesh(key: MeshType)-> Mesh {
        return meshes[key]!
    }
}
