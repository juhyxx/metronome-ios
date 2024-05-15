//
//  ContentView.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI
import AVFoundation
import CoreMotion

enum BeatValue: String, CaseIterable, Hashable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case none = "NONE"
    case subdivision = "SUBDIVISION"
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
        static let beats: [BeatValue] = [BeatValue.high, BeatValue.low, BeatValue.medium, BeatValue.low]
    }
}

struct TempoName {
    var value: Int
    var name: String
}

let tempoNames: [TempoName] = [
    TempoName(value: 60, name: "Largo"),
    TempoName(value: 66, name: "Larghetto"),
    TempoName(value: 76, name: "Adagio"),
    TempoName(value: 108, name: "Andante"),
    TempoName(value: 120, name: "Moderato"),
    TempoName(value: 168, name: "Allegro")
]

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
    
    let timer = DispatchSource.makeTimerSource()
    @State private var audioPlayer: AVAudioPlayer?
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let tick = UIImpactFeedbackGenerator(style: .heavy)
    private let tickSoft = UIImpactFeedbackGenerator(style: .soft)
    private var timeInterval:Double  {
        return 60.0 / Double((tempo * activeSubdivision))
    }
    @State private var currentSoundSet: [String:AVAudioPlayer] = [:]
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                BeatDisplay(beats: $beats, subdivisionCount: $activeSubdivision, activeSubBeat: $activeSubBeat, activeBeat: $activeBeat) .frame(height: geometry.size.height * 0.3)
                Spacer()
                HStack {
                    Text("SUBDIVS").textScale(Text.Scale.secondary)
                    Spacer()
                    ForEach(2...AppSettings.subdivisionMax, id: \.self) { index in
                       Toggle(isOn: Binding(
                           get: { activeSubdivision == index },
                           set: { newValue in
                               activeSubdivision = newValue ? index : 1
                           }
                       )) {
                           Text("\(index)")
                       }
                       .toggleStyle(.button)
                       .padding(0)
                   }
                }
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

                        Text("\(tempoToName(tempo: tempo))")
                        if (!CMMotionManager().isAccelerometerAvailable) {
                            TapToMeasureBPMButton(tempo: $tempo)
                        }
                        else {
                            Text("Shake")
                        }
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    HStack(spacing: 0)  {
                        ForEach(AppSettings.sounds.indices, id: \.self) { index in
                            Toggle(
                                isOn: Binding(
                                    get: { selectedSound == AppSettings.sounds[index] },
                                    set: { newValue in
                                        if newValue {
                                            selectedSound = AppSettings.sounds[index]
                                        }
                                    }
                                )
                            ) {
                                Text(LocalizedStringKey("sound-"+AppSettings.sounds[index]))
                            }
                            .toggleStyle(.button)
                            
                            .padding(0)
                            if index < AppSettings.sounds.count - 1  {
                                Spacer()
                            }
                        }
                    }
                }
                Button(isPlaying ? "stop":  "play", systemImage: isPlaying ? "stop.circle":  "play.circle") {
                    if isPlaying {
                        stopMetronome()
                    } else {
                        startMetronome()
                    }
                    impactGenerator.impactOccurred()
                }.controlSize(.large).buttonStyle(.borderedProminent)
            }
            .padding(5)
            .onChange(of: activeSubdivision) {
                if isPlaying {
                    stopMetronome()
                    startMetronome()
                }
            }
            .onChange(of: tempo) {
                if isPlaying {
                    stopMetronome()
                    startMetronome()
                }
            }
            .onChange(of: selectedSound) {
                loadSoundSet(soundSet: selectedSound)
            }
        }.onAppear {
            loadSoundSet(soundSet:AppSettings.defaultSound)
            UIApplication.shared.isIdleTimerDisabled = true // don't sleep
        }
        .onDisappear {
            stopMetronome()
        }
    }
  
    
    func startMetronome() {
        var prevTime:Date = Date.now

        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            print("\((timeInterval - (Date.now.timeIntervalSince1970 - prevTime.timeIntervalSince1970))*1000)ms \(timeInterval * 1000)ms")
            prevTime = Date.now
            var beatToPlay = BeatValue.subdivision
            var asb = activeSubBeat
            var ab = activeBeat
            
            asb += 1
            if asb >= activeSubdivision {
                asb = 0
                ab += 1
                if ab >= beats.count {
                    ab = 0
                }
                beatToPlay = beats[ab]
            }
          
            if beatToPlay == BeatValue.high {
               tick.impactOccurred()
            }
            //currentSoundSet[beatToPlay.rawValue.lowercased()]?.play()
            activeSubBeat = asb
            activeBeat = ab
        }
        timer.resume()
        isPlaying = true
    }
    
    func stopMetronome() {
        timer.suspend()
        isPlaying = false
    }
    
    func tempoToName(tempo: Int) -> String {
        if tempo < 66 {
            return "Largo"
        } else if tempo >= 168 {
            return "Presto"
        } else {
            // Najděte odpovídající jméno v seznamu
            if let match = tempoNames.last(where: { tempo >= $0.value }) {
                return match.name
            }
        }

        return ""
    }
    
    func loadSoundSet(soundSet: String) {
        for beat in BeatValue.allCases {
            if beat != BeatValue.none {
                let beatValue = beat.rawValue.lowercased()
                let sourcePath = "sounds/\(soundSet)/\(beatValue)"
                let dataAsset = NSDataAsset(name: sourcePath)
                if let data = dataAsset?.data {
                    do {
                        currentSoundSet[beatValue] =  try AVAudioPlayer(data: data)
                    } catch {
                        print("Chyba při přehrávání zvuku: \(error.localizedDescription)")
                    }
                }else {
                    print("missing data \(sourcePath)")
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
