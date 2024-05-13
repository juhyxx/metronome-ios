import SwiftUI



struct Beat: View {
    @Binding var value: BeatValue
    @Binding var subdivisionCount: Int
    @Binding var activeSubBeat: Int
    @Binding var activeBeat: Int
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let index: Int

    var body: some View {
        let highlight: Bool = activeBeat == index
        let op: Double = highlight ? 1 : 0.4
        let inactive = Color(.sRGB, white: 0.5, opacity: highlight ? 0.3 : 0.1)
        
        VStack (spacing:AppSettings.spacing) {
            Rectangle()
                .fill(value == .high ? Color.green.opacity(op) : inactive)
                .overlay(
                    Text("\(index + 1)")
                        .font(.largeTitle).opacity(op).bold()
                )
            Rectangle()
                .fill(value == .medium || value == .high ? Color.yellow.opacity(op) : inactive)
            Rectangle()
                .fill(value == .low || value == .medium || value == .high ? Color.red.opacity(op) : inactive)
            
            HStack(spacing: AppSettings.spacing) {
                ForEach(0..<subdivisionCount, id: \.self) { index in
                    Rectangle()
                        .fill(index == activeSubBeat  && highlight ?   Color.red : inactive)
                }
            }.frame(height: 10)
        }
        .contentShape(Rectangle())
        .onTapGesture { // Při kliknutí změna stavu
            rotateBeatValue()
            impactGenerator.impactOccurred()
        }
    }

    func rotateBeatValue() {
        switch value {
        case .high:
            value = .none
        case .medium:
            value = .high
        case .low:
            value = .medium
        default:
            value = .low
        }
    }
}


#Preview {
    Beat(value: .constant(BeatValue.medium),subdivisionCount:.constant(3), activeSubBeat: .constant(2),activeBeat:.constant(2), index: 1)
}
