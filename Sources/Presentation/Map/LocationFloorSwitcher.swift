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
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.12).opacity(0.95))

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.02),
                                Color.white.opacity(0.05),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.10),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                Ellipse()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 28, height: 12)
                    .blur(radius: 4)
                    .offset(y: -20)
            }
        }
        .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 6)
        .shadow(color: yellow.opacity(0.08), radius: 20, x: 0, y: 0)
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
                .shadow(color: yellow.opacity(0.4), radius: 6)
            Text("ЭТАЖ")
                .font(.system(size: 7, weight: .bold))
                .tracking(1)
                .foregroundColor(.white.opacity(0.3))
        }
    }

    private enum FloorDirection { case upfloor, downfloor }

    private func floorButton(direction: FloorDirection) -> some View {
        let isDisabled = direction == .upfloor ? !canSelectNextFloor : !canSelectPreviousFloor
        let icon = direction == .upfloor ? "chevron.up" : "chevron.down"

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                switch direction {
                case .upfloor:
                    onNextFloor()
                case .downfloor:
                    onPreviousFloor()
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDisabled ? .white.opacity(0.12) : .white.opacity(0.6))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(isDisabled ? 0 : 0.06))
                )
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
}
