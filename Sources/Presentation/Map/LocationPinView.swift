import SwiftUI

struct LocationPinView: View {
    let loc: LocationModel
    let isFocused: Bool
    let focusedLocId: String?
    let background: Color
    let yellow: Color
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            if isFocused {
                LocationPopupCard(loc: loc, background: background, yellow: yellow) {
                    onTap()
                }
                .offset(y: -56)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)))
            }

            VStack(spacing: 4) {
                pinIcon
                if !isFocused { pinLabel }
            }
            .opacity(focusedLocId != nil && !isFocused ? 0.5 : 1)
        }
        .onTapGesture { onTap() }
    }

    private var pinIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(loc.color)
                .frame(width: 36, height: 36)
                .overlay(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused ? yellow : Color.white.opacity(0.25),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                .shadow(color: isFocused ? yellow.opacity(0.4) : .clear, radius: 14)

            Image(systemName: loc.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .scaleEffect(isFocused ? 1.1 : (focusedLocId != nil ? 0.85 : 1.0))
    }

    private var pinLabel: some View {
        Text(loc.title.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(background.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
    }
}
