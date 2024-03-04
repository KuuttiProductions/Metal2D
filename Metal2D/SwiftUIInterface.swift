//
//  SwiftUIInterface.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 4.3.2024.
//

import SwiftUI
import Observation

@Observable 
class SwiftUIInterface {
    
    static var shared = SwiftUIInterface()

    var density: Float = 0.0
}
