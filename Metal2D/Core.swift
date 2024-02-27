//
//  Core.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import MetalKit

class Core {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    static func initialize(device: MTLDevice) {
        Core.device = device
        Core.commandQueue = device.makeCommandQueue()
    }
}
