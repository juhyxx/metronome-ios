import SwiftUI

struct TapToMeasureBPMButton: View {
    @State private var isClicked = false
    @Binding var tempo: Int
    @State private var timestamps: [Date] = []
    private let maxHistory = 5
    private let minBPM: Double = 40
    
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Button("Tap tempo") {
            impactGenerator.impactOccurred()
            isClicked.toggle()
            
            let now = Date()
            timestamps.append(now)
            
            if timestamps.count > maxHistory {
                timestamps.removeFirst()
            }
            
            if timestamps.count >= 2 {
                // Vypočítat časy mezi stisky
                let intervals = zip(timestamps, timestamps.dropFirst()).map { $1.timeIntervalSince($0) }
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
    @State static var tempo: Int = 0
    
    static var previews: some View {
        TapToMeasureBPMButton(tempo: $tempo)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
