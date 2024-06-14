//
//  MetronomeModel.swift
//  metronome
//
//  Created by Miroslav Juhos on 19.05.2024.
//

import Foundation
import SwiftUI
import AVFoundation

enum BeatValue: String, CaseIterable, Hashable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    case none = "NONE"
    case subdivision = "SUBDIVISION"
}


class MetronomeModel: ObservableObject {
    @Published var isPlaying: Bool = false
    
    @Published var activeBeat: Int = 0
    @Published var activeSubBeat:  Int = 0
    @Published var activeSubdivision:  Int = 1
    @Published var beats: [BeatValue] = AppSettings.Defaults.beats
    @Published var tempo: Int =  AppSettings.Defaults.tempo
    @Published var selectedSound: String = AppSettings.Defaults.sound
    @Published var currentSoundSet: [String:AVAudioPCMBuffer] = [:]
    
    private var duration:TimeInterval  {return 60.0 / Double((tempo * activeSubdivision))}
    
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,  sampleRate: Double(48000), channels: 2,  interleaved: true)!
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

            try AVAudioSession.sharedInstance().setActive(true)
      

            }
            catch {
                print(error)
                
        }
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format:audioFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
        audioPlayerNode.play()
        loadSoundSet(soundSet:AppSettings.defaultSound)
    }
    
    func start() {
        print("-----start------")
       
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
        audioPlayerNode.play()
        isPlaying = true
        scheduleNextBeat()
    }
    
    func stop() {
        isPlaying = false
        audioPlayerNode.stop()
        audioEngine.stop()
        activeSubBeat = 0
        activeBeat = 0
        
        print("-----stop------")
    }
    
    private func scheduleNextBeat() {
        let durationInNanoseconds:UInt64 =  UInt64(duration * Double(NSEC_PER_SEC) / 40)
        let hostTime = AVAudioTime(hostTime: (mach_absolute_time() + durationInNanoseconds))
        var subBeat =  self.activeSubBeat
        var beat =  self.activeBeat
        var beatToPlay = self.beats[beat]
        
       
        guard let audioBuffer = currentSoundSet[beatToPlay.rawValue.lowercased()] else {
            print(currentSoundSet)
            print("missing file")
            return
        }
        print("scheduleNextBeat \(beatToPlay) \(duration) \(hostTime.hostTime)")
        
        audioPlayerNode.scheduleBuffer(audioBuffer, at: hostTime, options: .interrupts, completionHandler: {
            print("sound completed")
            if (self.isPlaying) {
               // var beatToPlay = BeatValue.subdivision
                var subBeat =  self.activeSubBeat
                var beat =  self.activeBeat

                subBeat += 1
                if  subBeat >= self.activeSubdivision {
                    subBeat = 0
                    beat += 1
                    if beat >= self.beats.count {
                        beat = 0
                    }
                    beatToPlay = self.beats[beat]
                }
                

                DispatchQueue.main.async {
                    self.activeSubBeat = subBeat
                    self.activeBeat = beat
                }
                
                self.scheduleNextBeat()
            }
        })
    }
    
    
    func getNextBeat() -> BeatValue{
        var beatToPlay = BeatValue.subdivision
        var subBeat =  self.activeSubBeat
        var beat =  self.activeBeat

        subBeat += 1
        if  subBeat >= self.activeSubdivision {
            subBeat = 0
            beat += 1
            if beat >= self.beats.count {
                beat = 0
            }
            beatToPlay = self.beats[beat]
        }
        

        DispatchQueue.main.async {
            self.activeSubBeat = subBeat
            self.activeBeat = beat
        }
        return beatToPlay
    }
    
    func loadAudio(soundSet:String, beatValue:BeatValue) {
        
        
    }
    


    func loadSoundSet(soundSet: String) {
        print("---- \(soundSet) ----")
        var soundSetData: [String:AVAudioPCMBuffer] = [:]
        for beat in BeatValue.allCases {
            if beat != BeatValue.none {
                let beatValue:String = beat.rawValue.lowercased()
                let assetName:String = "sounds/\(soundSet)/\(beatValue)"
                guard let asset = NSDataAsset(name: assetName) else {
                    print("Asset not found: \(assetName)")
                    continue
                }
                
              
                let audioData = asset.data
                let frameCount = AVAudioFrameCount(audioData.count) / audioFormat.streamDescription.pointee.mBytesPerFrame
                guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount ) else {
                    print("Failed to create AVAudioPCMBuffer")
                    continue
                }
                buffer.frameLength = frameCount
                audioData.withUnsafeBytes {(audioBytes: UnsafeRawBufferPointer) in
                    let audioBuffer = buffer.audioBufferList.pointee.mBuffers
                    memcpy(audioBuffer.mData, audioBytes.baseAddress, Int(audioBuffer.mDataByteSize))
                }
                soundSetData[beatValue] = buffer
            }
            
        }
        
        audioPlayerNode.scheduleBuffer( soundSetData["high"]!)
       
        print("Loaded \(soundSetData)")
        DispatchQueue.main.async {
            self.currentSoundSet = soundSetData
            
        }
    }
}
