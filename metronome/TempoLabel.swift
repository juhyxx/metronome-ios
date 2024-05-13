import SwiftUI

struct TempoName {
    var value: Int
    var name: String
}

struct TempoLabel: View {
    @Binding var tempo: Int

    // Seznam jmen podle hodnot tempa
    let tempoNames: [TempoName] = [
        TempoName(value: 60, name: "Largo"),
        TempoName(value: 66, name: "Larghetto"),
        TempoName(value: 76, name: "Adagio"),
        TempoName(value: 108, name: "Andante"),
        TempoName(value: 120, name: "Moderato"),
        TempoName(value: 168, name: "Allegro")
    ]

    var body: some View {
        Text("\(tempoToName(tempo: tempo))")
    }

    // Funkce pro získání jména podle tempa
    func tempoToName(tempo: Int) -> String {
        if tempo < 66 {
            return "Largo"
        } else if tempo >= 168 {
            return "Presto"
        } else {
            // Najděte odpovídající jméno v seznamu
            if let match = tempoNames.last(where: { tempo >= $0.value }) {
                return match.name
            }
        }

        return ""
    }
}

#Preview {
    VStack {
        TempoLabel(tempo: .constant(60))
        TempoLabel(tempo: .constant(120))
        TempoLabel(tempo: .constant(220))
    }
}
