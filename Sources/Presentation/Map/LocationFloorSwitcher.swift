import SwiftUI

struct LocationFloorSwitcher: View {
    let floorNumber: Int
    let canSelectNextFloor: Bool
    let canSelectPreviousFloor: Bool
    let background: Color
    let yellow: Color
    let purple: Color
    let onNextFloor: () -> Void
    let onPreviousFloor: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            floorButton(direction: .upfloor)
            floorLabel
            floorButton(direction: .downfloor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.12))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .shadow(color: .black.opacity(0.45), radius: 12, x: 0, y: 4)
        .frame(width: 44)
    }

    private var floorLabel: some View {
        VStack(spacing: 2) {
            Text("\(floorNumber)")
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
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private enum FloorDirection { case upfloor, downfloor }

    private func floorButton(direction: FloorDirection) -> some View {
        let isDisabled = direction == .upfloor ? !canSelectNextFloor : !canSelectPreviousFloor
        let icon = direction == .upfloor ? "chevron.up" : "chevron.down"

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                switch direction {
                case .upfloor: onNextFloor()
                case .downfloor: onPreviousFloor()
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDisabled ? .white.opacity(0.15) : .white.opacity(0.7))
                .frame(width: 32, height: 32)
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
}
