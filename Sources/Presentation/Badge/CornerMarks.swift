import SwiftUI

struct CornerMarks: View {
    let color: Color
    let length: CGFloat = 14
    let width: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: length))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: length, y: 0))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - length, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: length))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height - length))
                    path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    path.addLine(to: CGPoint(x: length, y: geo.size.height))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - length, y: geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - length))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
        }
    }
}
