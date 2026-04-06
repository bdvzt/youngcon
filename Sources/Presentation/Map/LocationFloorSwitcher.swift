import SwiftUI

struct LocationFloorSwitcher: View {
    @Binding var floor: Int
    let background: Color
    let yellow: Color
    let purple: Color
    let onFloorChange: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            floorButton(direction: .upfloor)
            floorLabel
            floorButton(direction: .downfloor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(background.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
        .frame(width: 44)
    }

    private var floorLabel: some View {
        VStack(spacing: 2) {
            Text("\(floor)")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [yellow, purple],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            Text("ЭТАЖ")
                .font(.system(size: 7, weight: .bold))
                .tracking(1)
                .foregroundColor(.white.opacity(0.2))
        }
    }

    private enum FloorDirection { case upfloor, downfloor }

    private func floorButton(direction: FloorDirection) -> some View {
        let isDisabled = direction == .upfloor ? floor == 2 : floor == 1
        let icon = direction == .upfloor ? "chevron.up" : "chevron.down"

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                floor = direction == .upfloor ? 2 : 1
                onFloorChange()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isDisabled ? .white.opacity(0.15) : .white.opacity(0.5))
                .frame(width: 32, height: 32)
        }
        .disabled(isDisabled)
    }
}
