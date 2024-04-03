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

    var value1: Float = 0
    var value2: Float = 0
    var value3: Float = 0
    var value4: Float = 0
    var value5: Float = 0
}
