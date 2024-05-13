import SwiftUI

// Komponenta, která umožňuje výběr jednoho ze zvuků
struct SoundSelector: View {
    @Binding var selectedSound: String // Přijímá zvuk, který je vybrán

    let sounds = AppSettings.sounds

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0)  {
                ForEach(sounds.indices, id: \.self) { index in
                    Toggle(
                        isOn: Binding(
                            get: { selectedSound == sounds[index] },
                            set: { newValue in
                                if newValue {
                                    selectedSound = sounds[index]
                                }
                            }
                        )
                    ) {
                        Text(LocalizedStringKey("sound-"+sounds[index]))
                    }
                    .toggleStyle(.button)
                    
                    .padding(0)
                    if index < sounds.count - 1  {
                        Spacer()
                    }
                }
            }
        }
       
    }
}


#Preview {
    SoundSelector(selectedSound: .constant("beep"))
}
