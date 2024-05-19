import SwiftUI

struct BeatDisplay: View {
    @StateObject var model = MetronomeModel()
    
    
    var body: some View {
        VStack{
            HStack(spacing: AppSettings.spacing) {
                ForEach(model.beats.indices, id: \.self) { index in
                    Beat(
                        value: $model.beats[index],
                        subdivisionCount: $model.activeSubdivision,
                        activeSubBeat: $model.activeSubBeat,
                        isActive: Binding(
                            get: { model.activeBeat == index },
                            set: { _ in }
                        ),
                        index: index
                    )
                }
            }
            HStack {
                Text("\(model.activeBeat + 1):\(model.activeSubBeat + 1)")
                Spacer()
                Button("add",systemImage: "plus.circle", action: {
                    if model.beats.count < 9 {
                        model.beats.append(BeatValue.low)
                    }
                }).disabled($model.beats.count >= 9)
                Button("remove",systemImage: "minus.circle", action: {
                    if model.beats.count > 1 {
                        model.beats.removeLast()
                    }
                }).disabled($model.beats.count <= 1)
            }
        }
    }
}

#Preview {
    @State var beats = [BeatValue.low, BeatValue.high, BeatValue.medium, BeatValue.none]
    @State var subdivisionCount = 3
    @State var activeSubBeat = 1
    @State var activeBeat = 4
    
    return BeatDisplay()
}
