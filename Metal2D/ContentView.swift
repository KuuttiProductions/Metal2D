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
            GameView()
        }
        .fontDesign(.monospaced)
    }
}

#Preview {
    ContentView()
}
