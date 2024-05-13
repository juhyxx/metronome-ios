import SwiftUI

struct BeatDisplay: View {
    @Binding var beats: [BeatValue]
    @Binding var subdivisionCount: Int
    @Binding var activeSubBeat: Int
    @Binding var activeBeat: Int

    
    var body: some View {
        VStack{
            HStack(spacing: AppSettings.spacing) {
                ForEach(beats.indices, id: \.self) { index in
                    Beat(
                        value: $beats[index],
                        subdivisionCount: $subdivisionCount,
                        activeSubBeat: $activeSubBeat,
                        activeBeat: $activeBeat,
                        index: index
                    )
                }
            }
            HStack {
                Text("\(activeBeat + 1):\(activeSubBeat + 1)")
                Spacer()
                Button("add",systemImage: "plus.circle", action: {
                    if beats.count < 9 {
                        beats.append(BeatValue.low)
                    }
                }).disabled($beats.count >= 9)
                Button("remove",systemImage: "minus.circle", action: {
                    if beats.count > 1 {
                        beats.removeLast()
                    }
                }).disabled($beats.count == 1)
            }
        }
    }
}

#Preview {
    @State var beats = [BeatValue.low, BeatValue.high, BeatValue.medium, BeatValue.none]
      @State var subdivisionCount = 3
      @State var activeSubBeat = 1
      @State var activeBeat = 4

      return BeatDisplay(
          beats: $beats,
          subdivisionCount: $subdivisionCount,
          activeSubBeat: $activeSubBeat,
          activeBeat: $activeBeat
      )
}
