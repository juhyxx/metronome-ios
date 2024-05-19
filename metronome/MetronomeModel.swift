//
//  MetronomeModel.swift
//  metronome
//
//  Created by Miroslav Juhos on 19.05.2024.
//

import Foundation
import SwiftUI
import AVFoundation


class MetronomeModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var worker:DispatchWorkItem? = nil
    @Published var activeBeat: Int = 0
    @Published var activeSubBeat:  Int = 0
    @Published var activeSubdivision:  Int = 1
    @Published var beats: [BeatValue] = AppSettings.Defaults.beats
    @Published var tempo: Int =  AppSettings.Defaults.tempo
    @Published var selectedSound: String = AppSettings.Defaults.sound
    @Published var currentSoundSet: [String:AVAudioPlayer] = [:]
    
    let queue = DispatchQueue(label: "metroQueue", qos: .userInteractive)
    private var timeInterval:Double  {return 60.0 / Double((tempo * activeSubdivision))}

    
    func start() {
        isPlaying = true
        playBeat(at: DispatchTime.now())
    }
    
    func stop() {
        worker?.cancel()
        isPlaying = false
        activeSubBeat = 0
        activeBeat = 0
    }
    
    func playBeat(at: DispatchTime) {
        worker = DispatchWorkItem(block: {
            
            var beatToPlay = BeatValue.subdivision
            var asb = self.activeSubBeat
            var ab = self.activeBeat
            
            asb += 1
            if asb >= self.activeSubdivision {
                asb = 0
                ab += 1
                if ab >= self.beats.count {
                    ab = 0
                }
                beatToPlay = self.beats[ab]
            }
            
            let sound = self.currentSoundSet[beatToPlay.rawValue.lowercased()]
            sound?.play()
            self.activeSubBeat = asb
            self.activeBeat = ab
            if self.isPlaying {
                self.playBeat(at: at + self.timeInterval)
            }
        })
        queue.asyncAfter(deadline: at, execute: worker!)
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
