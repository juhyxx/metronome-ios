//
//  ContentView.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI
import AVFoundation

struct AppSettings {
    static let subdivisionMax: Int = 6
    static let minTempo: Int = 40
    static let maxTempo: Int = 280
    static let sounds:[String] = ["sticks", "drums", "classic", "beep"]
    static let spacing: CGFloat = 2
   
}

enum BeatValue: String {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case none = "NONE"
}


struct ContentView: View {
    @State var subdivision:  Int = 1
    @State var activeSubBeat:  Int = 3
    @State private var selectedSound: String = "sticks"
    @State var tempo: Int = 120
    @State var beats: [BeatValue] = [BeatValue.high, BeatValue.low, BeatValue.low, BeatValue.low]
    @State var activeBeat: Int = 1
    
    @State private var minTempo: Int = AppSettings.minTempo
    @State private var maxTempo: Int = AppSettings.maxTempo
    @State private var isPlaying: Bool = false
    
    @State private var timer: Timer?
    @State var audioPlayer: AVAudioPlayer?
    
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let tick = UIImpactFeedbackGenerator(style: .heavy)
    let tickSoft = UIImpactFeedbackGenerator(style: .soft)

    var body: some View {
        var timeInt:Double = 60.0 / Double((tempo * subdivision))
        GeometryReader { geometry in
            VStack {
               
                BeatDisplay(beats: $beats, subdivisionCount: $subdivision, activeSubBeat: $activeSubBeat, activeBeat: $activeBeat) .frame(height: geometry.size.height * 0.3)
                Subdivisions(selected:$subdivision)
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
                        TapToMeasureBPMButton(tempo: $tempo)
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
            .padding(2)
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
                if activeSubBeat >= subdivision {
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
            timer?.invalidate() // Zastavení časovače
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
