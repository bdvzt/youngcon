import SwiftUI

struct ScheduleFilterBar: View {
    let filters: [ScheduleFilter]
    @Binding var activeFilter: ScheduleFilter

    private let yellow = YoungConAsset.accentYellow.swiftUIColor
    private let liveRed = Color(red: 0.99, green: 0.25, blue: 0.11)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func filterChip(_ filter: ScheduleFilter) -> some View {
        let isActive = activeFilter == filter
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { activeFilter = filter }
        } label: {
            HStack(spacing: 5) {
                if filter == .live {
                    Circle()
                        .fill(liveRed)
                        .frame(width: 6, height: 6)
                }
                if filter == .favorites {
                    Image(systemName: isActive ? "star.fill" : "star")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(filter.rawValue)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(chipBackground(filter, isActive: isActive))
            .foregroundColor(chipForeground(filter, isActive: isActive))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(chipStroke(filter, isActive: isActive), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .shadow(color: isActive ? yellow.opacity(0.25) : .clear, radius: 12)
    }

    private func chipBackground(_ filter: ScheduleFilter, isActive: Bool) -> Color {
        if isActive { return yellow }
        if filter == .favorites { return yellow.opacity(0.04) }
        if filter == .live { return liveRed.opacity(0.04) }
        return Color.white.opacity(0.02)
    }

    private func chipForeground(_ filter: ScheduleFilter, isActive: Bool) -> Color {
        if isActive { return .black }
        if filter == .favorites { return yellow.opacity(0.7) }
        if filter == .live { return liveRed.opacity(0.7) }
        return .white.opacity(0.35)
    }

    private func chipStroke(_ filter: ScheduleFilter, isActive: Bool) -> Color {
        if isActive { return yellow.opacity(0.4) }
        if filter == .favorites { return yellow.opacity(0.15) }
        if filter == .live { return liveRed.opacity(0.15) }
        return Color.white.opacity(0.06)
    }
}
