//
//  ContentView.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI
import AVFoundation
import CoreMotion

enum BeatValue: String {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case none = "NONE"
}

struct AppSettings {
    static let subdivisionMax: Int = 6
    static let minTempo: Int = 40
    static let maxTempo: Int = 300
    static let sounds:[String] = ["sticks", "drums", "classic", "beep"]
    static let spacing: CGFloat = 2
    static let defaultSound: String = AppSettings.sounds[0]
    
    struct Defaults {
        static let sound: String = "sticks"
        static let tempo: Int = 120
        static let beats: [BeatValue] = [BeatValue.high, BeatValue.low, BeatValue.low, BeatValue.low]
    }
}


struct ContentView: View {
    @State private var activeSubdivision:  Int = 1
    @State private var activeBeat: Int = 0
    @State private var activeSubBeat:  Int = 0

    @State private var tempo: Int =  AppSettings.Defaults.tempo
    @State private var isPlaying: Bool = false

    @State private var selectedSound: String = AppSettings.Defaults.sound
    @State private var beats: [BeatValue] = AppSettings.Defaults.beats
    @State private var minTempo: Int = AppSettings.minTempo
    @State private var maxTempo: Int = AppSettings.maxTempo
    
    @State private var timer: Timer?
    @State private var audioPlayer: AVAudioPlayer?
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let tick = UIImpactFeedbackGenerator(style: .heavy)
    private let tickSoft = UIImpactFeedbackGenerator(style: .soft)
    private var  timeInt:Double  {
        return 60.0 / Double((tempo * activeSubdivision))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                BeatDisplay(beats: $beats, subdivisionCount: $activeSubdivision, activeSubBeat: $activeSubBeat, activeBeat: $activeBeat) .frame(height: geometry.size.height * 0.3)
                Subdivisions(selected:$activeSubdivision)
                Spacer()
                HStack{
                    VStack {
                        Picker("Select tempo", selection: $tempo) {
                            ForEach($minTempo.wrappedValue...$maxTempo.wrappedValue, id: \.self) { value in
                                Text("\(value)").foregroundColor(value % 10 == 0 ? .accentColor : .primary)
                            }
                        }.pickerStyle(WheelPickerStyle()).frame(width: 110)
                    }
                    VStack{
                        TempoLabel(tempo: $tempo)
                        if (!CMMotionManager().isAccelerometerAvailable) {
                            TapToMeasureBPMButton(tempo: $tempo)
                        }
                        else {
                           Text("Shake")
                        }
                    }
                }
                Spacer()
                SoundSelector(selectedSound: $selectedSound)
                Button(isPlaying ? "stop":  "play", systemImage: isPlaying ? "stop.circle":  "play.circle") {
                    if isPlaying {
                        stopMetronome()
                    } else {
                        startMetronome(timeInt:timeInt)
                    }
                    impactGenerator.impactOccurred()
                }.controlSize(.large).buttonStyle(.borderedProminent)
            }
            .padding(5)
            .onChange(of: activeSubdivision) {
                if isPlaying {
                    stopMetronome()
                    startMetronome(timeInt:timeInt)
                }
            }
            .onChange(of: tempo) {
                if isPlaying {
                    stopMetronome()
                    startMetronome(timeInt:timeInt)
                }
            }
        }.onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopMetronome()
        }
    }
    
    func startMetronome(timeInt:Double) {
        timer = Timer.scheduledTimer(
            withTimeInterval: timeInt,
            repeats: true
        ) { _ in
            activeSubBeat += 1
            if activeSubBeat >= activeSubdivision {
                activeSubBeat = 0
                activeBeat += 1
                tick.impactOccurred()
                if activeBeat >= beats.count {
                    activeBeat = 0
                }
            }
            else {
                tickSoft.impactOccurred()
            }
            playSound()
        }
        isPlaying = true
    }
    
    func stopMetronome() {
        timer?.invalidate() 
        timer = nil
        isPlaying = false
    }
    
    func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: selectedSound, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Chyba při inicializaci zvukového přehrávače: \(error)")
            }
        }
    }
    
    func playSound() {
        audioPlayer?.play() // Přehrání zvuku
    }
}

#Preview {
    ContentView()
}
