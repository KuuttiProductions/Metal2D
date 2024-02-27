//
//  Scene.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class GameScene {
    
    var children: [Node] = []
    
    func addChild(node: Node) {
        children.append(node)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        for child in children {
            child.render(renderCommandEncoder: renderCommandEncoder, deltaTime: deltaTime)
        }
    }
}
