import SwiftUI

struct TabItemView: View {
    let tab: AppTab
    let isActive: Bool
    let action: () -> Void

    private let activeColor   = YoungConAsset.accentYellow.swiftUIColor
    private let inactiveColor = YoungConAsset.gray500.swiftUIColor

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isActive {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        activeColor.opacity(0.55),
                                        activeColor.opacity(0),
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 26
                                )
                            )
                            .frame(width: 52, height: 28)
                            .blur(radius: 6)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? activeColor : inactiveColor)
                        .shadow(
                            color: isActive ? activeColor.opacity(0.6) : .clear,
                            radius: 6
                        )
                }
                .frame(width: 44, height: 32)

                Text(tab.label)
                    .font(.system(size: 10, weight: .bold))
                    .kerning(0.8)
                    .textCase(.uppercase)
                    .foregroundColor(isActive ? activeColor : inactiveColor)
            }
            .offset(y: isActive ? -4 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
