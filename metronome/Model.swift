//
//  Model.swift
//  metronome
//
//  Created by Miroslav Juhos on 09.04.2024.
//

import Foundation

enum BeatLevel{
    case None
    case Low
    case Medium
    case High
    
}


class Beat{
    private var level:BeatLevel = BeatLevel.None
    
    init(level: BeatLevel = BeatLevel.None) {
        self.level = level
    }
    
    
}

@Observable
class BeatModel{
    var data: [Beat] = [Beat(level: BeatLevel.High), Beat(), Beat(), Beat()]
    func add() {
        if(data.count < 10) {
            data.append(Beat())
        }
       
        print("add", data.count)
    }
    func remove() {
        if(data.count > 1) {
            data.removeLast()
        }
     
        print("remove", data.count)
    }
    
}


@Observable
class MetroModel{
    
    var beats: BeatModel = BeatModel()
    
    var tempo: Double = 110;
    
    func tap() {
        print("Tap")
        tempo = 200
    }
    
    
    

   
}


