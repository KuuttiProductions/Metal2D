//
//  ContentView.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 27.2.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State var interface = SwiftUIInterface.shared
    
    var body: some View {
        VStack {
            Text(String(interface.value1))
            Text(String(interface.value2))
            Text(String(interface.value3))
            Text(String(interface.value4))
            Text(String(interface.value5))
            GameView()
        }
        .fontDesign(.monospaced)
        .font(.largeTitle)
    }
}

#Preview {
    ContentView()
}
