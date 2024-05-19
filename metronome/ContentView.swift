//
//  ContentView.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI

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
    @StateObject private var model = MetronomeModel()

    var body: some View {
        GeometryReader { geometry in
            VStack {
                BeatDisplay(model: model) .frame(height: geometry.size.height * 0.3)
                Spacer()
                HStack {
                    Text("SUBDIVS").textScale(Text.Scale.secondary)
                    Spacer()
                    ForEach(2...AppSettings.subdivisionMax, id: \.self) { index in
                        Toggle(isOn: Binding(
                            get: { model.activeSubdivision == index },
                            set: { newValue in
                                model.activeSubdivision = newValue ? index : 1
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
                        Picker("Select tempo", selection: $model.tempo) {
                            ForEach(AppSettings.minTempo...AppSettings.maxTempo, id: \.self) { value in
                                Text("\(value)").foregroundColor(value % 10 == 0 ? .accentColor : .primary)
                            }
                        }.pickerStyle(WheelPickerStyle()).frame(width: 110)
                    }
                    VStack{
                        Text("\(tempoToName(tempo: model.tempo))")
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    HStack(spacing: 0)  {
                        ForEach(AppSettings.sounds.indices, id: \.self) { index in
                            Toggle(
                                isOn: Binding(
                                    get: { model.selectedSound == AppSettings.sounds[index] },
                                    set: { newValue in
                                        if newValue {
                                            model.selectedSound = AppSettings.sounds[index]
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
                Button(model.isPlaying ? "stop":  "play", systemImage: model.isPlaying ? "stop.circle":  "play.circle") {
                    if model.isPlaying {
                        model.stop()
                    } else {
                        model.start()
                    }
                
                }.controlSize(.large).buttonStyle(.borderedProminent)
            }
            .padding(5)
            .onChange(of: model.selectedSound) {
                model.loadSoundSet(soundSet: model.selectedSound)
            }
        }.onAppear {
            model.loadSoundSet(soundSet:AppSettings.defaultSound)
            UIApplication.shared.isIdleTimerDisabled = true // don't sleep
        }
        .onDisappear {
            model.stop()
        }
    }
    
    func tempoToName(tempo: Int) -> String {
        if tempo < 66 {
            return "Largo"
        } else if tempo >= 168 {
            return "Presto"
        } else {
            if let match = tempoNames.last(where: { tempo >= $0.value }) {
                return match.name
            }
        }
        return ""
    }
}


#Preview {
    ContentView()
}
