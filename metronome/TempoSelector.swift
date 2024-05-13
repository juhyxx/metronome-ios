import SwiftUI

// Vlastní tvar pro vykreslení značek
struct CircleMarks: Shape {
    var startAngle: Double
    var endAngle: Double
    var minTempo: Int
    var maxTempo: Int
    var step: Int
    var radius: CGFloat
    var length: CGFloat // Délka značky
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        
        for tempo in stride(from: minTempo, to: maxTempo + 1, by: step) {
           
            let relativePosition = Double(tempo - minTempo) / Double(maxTempo - minTempo)
            let angle = (startAngle + relativePosition * (endAngle - startAngle) ).truncatingRemainder(dividingBy: 360)
          
            let outerPoint = CGPoint(
                x: center.x + (radius - length/2) * CGFloat(cos(angle * .pi / 180)), // vnější bod
                y: center.y + (radius - length/2) * CGFloat(sin(angle * .pi / 180)) // vnější bod
            )
            let innerPoint = CGPoint(
                x: center.x + (radius - length) * CGFloat(cos(angle * .pi / 180)), // vnitřní bod
                y: center.y + (radius - length) * CGFloat(sin(angle * .pi / 180)) // vnitřní bod
            )
          
            path.move(to: outerPoint)
            path.addLine(to: innerPoint) // Přidání značky do cesty
        }
        
        return path
    }
}

struct TempoSelector: View {
    @Binding var tempo: Int
    private let minTempo: Int = 40
    private let maxTempo: Int = 280
    private let startAngle: Double = 120
    private let endAngle: Double = 420
    
    

    var body: some View {
        GeometryReader { geometry in
            let radius = (min(geometry.size.width, geometry.size.height) / 2) - 20
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // Obrys částečného kruhu
                Arc(startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), radius: radius)
                    .stroke(Color.secondary, lineWidth: 4)

                // Vykreslení značek najednou
                CircleMarks(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    minTempo: minTempo,
                    maxTempo: maxTempo,
                    step: 10,
                    radius: radius,
                    length: 20 // Délka značek
                )
                .stroke(Color.accentColor, lineWidth: 3)

                // Ukazatel pro aktuální tempo
                let relativePosition = (Double(tempo - minTempo) / Double(maxTempo - minTempo))
                let currentAngle = (startAngle + relativePosition * (endAngle - startAngle)).truncatingRemainder(dividingBy: 360)
                let normalizedAngle = currentAngle.truncatingRemainder(dividingBy: 360)
                let currentPoint = CGPoint(
                    x: center.x + radius * CGFloat(cos(normalizedAngle * .pi / 180)),
                    y: center.y + radius * CGFloat(sin(normalizedAngle * .pi / 180))
                )

                Line(from: center, to: currentPoint) // Ukazatel
                    .stroke(Color.red, lineWidth: 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    let dx = Double(value.location.x - center.x)
                    let dy = Double(value.location.y - center.y)
                    let angle = atan2(dy, dx) * 180 / .pi

                    let normalizedAngle = angle >= 0 ? angle : angle + 360
                    let adjustedAngle = max(startAngle, min(normalizedAngle, endAngle)).truncatingRemainder(dividingBy: 360)
                    let relativeAngle = (adjustedAngle - startAngle) / (endAngle - startAngle)
                    let calculatedTempo = Int(Double(minTempo) + relativeAngle * Double(maxTempo - minTempo))
                    tempo = min(max(calculatedTempo, minTempo), maxTempo) // Udržet v mezích
                }
            )
        } .contentShape(Rectangle())
        .frame(width: 300, height: 300) // Rozměr komponenty
    }
}

// Pomocná třída pro kreslení čar
struct Line: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

// Pomocná třída pro kreslení oblouku
struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}



#Preview {
    TempoSelector(tempo:.constant(280))
}


