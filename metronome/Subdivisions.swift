//
//  Subdivisions.swift
//  metronome
//
//  Created by Miroslav Juhos on 08.04.2024.
//

import SwiftUI

struct Subdivisions: View {
    
    @Binding var selected: Int


    var body: some View {
        HStack {
            Text("SUBDIVS").textScale(Text.Scale.secondary)
            Spacer()
            ForEach(2...AppSettings.subdivisionMax, id: \.self) { index in
               Toggle(isOn: Binding(
                   get: { selected == index },
                   set: { newValue in
                       selected = newValue ? index : 1
                   }
               )) {
                   Text("\(index)")
               }
               .toggleStyle(.button)
               .padding(0)
           }
        }
  
    }
}

#Preview {
    @State var selected = 2
    
   return  Subdivisions(selected: $selected)
}
