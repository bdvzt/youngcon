import SwiftUI

struct ScannerCorner: View {
    var body: some View {
        Path { path in
            let w: CGFloat = 30
            path.move(to: CGPoint(x: 0, y: w))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
        }
        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        .foregroundColor(.white)
        .overlay(
            Path { path in
                let w: CGFloat = 30
                path.move(to: CGPoint(x: 0, y: w))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        )
        .shadow(color: .white.opacity(0.4), radius: 4, x: 0, y: 0)
    }
}
