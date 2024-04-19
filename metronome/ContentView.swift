//
//  ContentView.swift
//  metronome
//
//  Created by Miroslav Juhos on 25.03.2024.
//

import SwiftUI

struct ContentView: View {
    @State var model = MetroModel()

    
    var body: some View {
        Text("name")
        VStack {
            Text("Tempo")
            Text(String(model.tempo))
            Text(String($model.beats.data.count))
            Slider(value: $model.tempo, in: 0...300, step: 1)
            Spacer()
            Subdivisions()
            Spacer()
            VStack {
                Text("beats")
                HStack {
                    Button("add", systemImage: "plus") {
                        model.beats.add()
                    }
                    Button("remove", systemImage: "minus") {
                        model.beats.remove()
                    }
                    
               }.buttonStyle(.bordered)
            }.frame(maxWidth: .infinity)
       
            Button("Tap") {
                model.tap()
            }.buttonStyle(.borderedProminent).controlSize(.extraLarge)
            
            HStack {
                Button("sound-sticks") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }  
                Spacer()
                Button("sound-drums") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                Spacer()
                Button("sound-metronome") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                Spacer()
                Button("sound-beep") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
            
            }.buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
    
    }
     
}

#Preview {
    ContentView().environment(MetroModel())
}
