//
//  metronomeApp.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI

struct AppSettings {
    static let subdivisionMax: Int = 6
    static let minTempo: Int = 40
    static let maxTempo: Int = 300
    static let sounds:[String] = ["sticks2", "drums", "classic", "beep"]
    static let spacing: CGFloat = 2
    static let defaultSound: String = AppSettings.sounds[0]
    
    struct Defaults {
        static let sound: String = "sticks"
        static let tempo: Int = 120
        static let beats: [BeatValue] = [BeatValue.high, BeatValue.low, BeatValue.medium, BeatValue.low]
    }
}

@main
struct metronomeApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
