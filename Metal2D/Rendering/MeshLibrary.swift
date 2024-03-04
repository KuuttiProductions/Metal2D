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
    case Circle
}

class MeshLibrary {
    
    private static var meshes: [MeshType : Mesh] = [:]
    
    static func initialize() {
        MeshLibrary.meshes.updateValue(TriangleMesh(), forKey: .Triangle)
        MeshLibrary.meshes.updateValue(QuadMesh(), forKey: .Quad)
        MeshLibrary.meshes.updateValue(CircleMesh(), forKey: .Circle)
    }
    
    static func getMesh(key: MeshType)-> Mesh {
        return meshes[key]!
    }
}
