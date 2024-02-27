//
//  SandboxScene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import Foundation

class SandboxScene: GameScene {
    override init() {
        super.init()
        addChild(node: Node(name: "Triangle"))
    }
}
