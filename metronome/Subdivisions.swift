//
//  Subdivisions.swift
//  metronome
//
//  Created by Miroslav Juhos on 08.04.2024.
//

import SwiftUI

struct Subdivisions: View {
    
    @State var selected2: Bool = false
    @State var selected3: Bool = false
    @State var selected4: Bool = false
    @State var selected5: Bool = false
    @State var selected6: Bool = false
    
    @State var selections: [Bool] = [true, false,false,false,false]
    
 

    
    var body: some View {
        GroupBox(label:  Text("subdivisions")) {
           
            HStack {
                Toggle(isOn: $selections[0]){
                    Text("2")
                }.id(0)
                Toggle(isOn: $selections[1]) {
                    Text("3")
                }.id(1)
                Toggle(isOn: $selections[2]) {
                    Text("4")
                }.id(2)
                Toggle(isOn:$selections[3]) {
                    Text("5")
                }.id(3)
                Toggle(isOn: $selections[4]) {
                    Text("6")
                }.id(4)
            }.toggleStyle(.button)
            
        }
  
    }
}

#Preview {
    Subdivisions()
}
