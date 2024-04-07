//
//  Metal2DApp.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import SwiftUI

@main
struct Metal2DApp: App {
    
    init() {
        Core.initialize(device: MTLCreateSystemDefaultDevice()!)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("FISIKS")
        }
    }
}
