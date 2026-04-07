import SwiftUI

struct LocationPopupCard: View {
    let zone: Zone
    let background: Color
    let yellow: Color
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardContent
            arrowTip
        }
        .frame(width: 200)
        .onTapGesture {}
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            cardHeader
            Text(zone.description)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(background.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 15)
    }

    private var cardHeader: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(zone.color)
                        .frame(width: 28, height: 28)
                    ZoneIconImage(url: zone.icon, placeholderFontSize: 12)
                        .frame(width: 14, height: 14)
                }
                Text(zone.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            closeButton
        }
    }

    private var closeButton: some View {
        Button { onClose() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var arrowTip: some View {
        Rectangle()
            .fill(background.opacity(0.95))
            .frame(width: 12, height: 12)
            .rotationEffect(.degrees(45))
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .rotationEffect(.degrees(45))
            )
            .frame(maxWidth: .infinity)
            .offset(y: -6)
    }
}
