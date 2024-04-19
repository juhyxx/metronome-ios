//
//  metronomeApp.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI

@main
struct metronomeApp: App {
    @State private var model = MetroModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(model)
        }
    }
}
