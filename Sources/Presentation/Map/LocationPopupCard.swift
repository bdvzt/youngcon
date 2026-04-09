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
        .frame(width: 240)
        .onTapGesture {}
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("map.popup.\(zone.id)")
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
    }

    private var cardHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(zone.color)
                    .frame(width: 28, height: 28)

                ZoneIconImage(url: zone.icon, placeholderFontSize: 12)
                    .frame(width: 14, height: 14)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("map.popup.icon.\(zone.id)")
            .accessibilityLabel(zone.title)

            Text(zone.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .allowsTightening(true)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .accessibilityIdentifier("map.popup.title.\(zone.id)")

            closeButton
        }
    }

    private var closeButton: some View {
        Button {
            onClose()
        } label: {
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
        .accessibilityIdentifier("map.popup.close")
    }

    private var arrowTip: some View {
        ArrowTipShape()
            .fill(background.opacity(0.95))
            .frame(width: 16, height: 8)
            .overlay(
                ArrowTipShape()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 16, height: 8)
            )
            .frame(maxWidth: .infinity)
            .offset(y: -1)
    }
}

private struct ArrowTipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - rect.width / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
