import SwiftUI

struct TapToMeasureBPMButton: View {
    @State private var isClicked = false
    @Binding var tempo: Int // Proměnná, do které se nastaví výsledné BPM
    @State private var timestamps: [Date] = [] // Historie stisknutí
    private let maxHistory = 5 // Maximální počet stisknutí k zapamatování
    private let minBPM: Double = 40 // Minimální BPM, při kterém se bude počítat
    
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        Button("Tap tempo") {
            impactGenerator.impactOccurred()
       
            isClicked.toggle() // Změnit stav při kliknutí
               
            let now = Date() // Aktuální čas stisknutí
            timestamps.append(now) // Přidání do historie

            if timestamps.count > maxHistory {
                timestamps.removeFirst() // Udržet pouze posledních pět
            }

            if timestamps.count >= 2 {
                // Vypočítat časy mezi stisky
                let intervals = zip(timestamps, timestamps.dropFirst())
                    .map { $1.timeIntervalSince($0) }

         
                let bpms = intervals.map { 60.0 / $0 }

             
                let averageBPM = bpms.reduce(0.0, +) / Double(bpms.count)

                if averageBPM >= minBPM {
                    tempo = Int(averageBPM) // Nastavit výsledné BPM
                }
            }
        }   .frame(width: 80, height: 80)
            .foregroundColor(Color.primary)
            .background(isClicked ? Color.secondary : Color.accentColor)
            .clipShape(Circle())
            .contentShape(Circle())
           
    }
}

// Ukázka pro testování komponenty
struct TapToMeasureBPM_Previews: PreviewProvider {
    @State static var tempo: Int = 0 // Proměnná pro testování

    static var previews: some View {
        TapToMeasureBPMButton(tempo: $tempo) // Předání Binding proměnné
            .previewLayout(.sizeThatFits) // Velikost náhledu
            .padding() // Odsazení kolem komponenty
    }
}
