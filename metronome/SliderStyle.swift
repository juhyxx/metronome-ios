//
//  SliderStyle.swift
//  metronome
//
//  Created by Miroslav Juhos on 16.04.2024.
//

import SwiftUI



struct SliderStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.black)
      .padding()
  }
}
