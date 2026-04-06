import SwiftUI

struct ScheduleFilterBar: View {
    let filters: [String]
    @Binding var activeFilter: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func filterChip(_ filter: String) -> some View {
        let isActive = activeFilter == filter
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { activeFilter = filter }
        } label: {
            HStack(spacing: 5) {
                if filter == "Live" {
                    Circle()
                        .fill(AppColor.liveRed)
                        .frame(width: 6, height: 6)
                }
                if filter == "Избранное" {
                    Image(systemName: isActive ? "star.fill" : "star")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(filter)
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
        .shadow(color: isActive ? AppColor.accentYellow.opacity(0.25) : .clear, radius: 12)
    }

    private func chipBackground(_ filter: String, isActive: Bool) -> Color {
        if isActive { return AppColor.accentYellow }
        if filter == "Избранное" { return AppColor.accentYellow.opacity(0.04) }
        if filter == "Live" { return AppColor.liveRed.opacity(0.04) }
        return Color.white.opacity(0.02)
    }

    private func chipForeground(_ filter: String, isActive: Bool) -> Color {
        if isActive { return .black }
        if filter == "Избранное" { return AppColor.accentYellow.opacity(0.7) }
        if filter == "Live" { return AppColor.liveRed.opacity(0.7) }
        return .white.opacity(0.35)
    }

    private func chipStroke(_ filter: String, isActive: Bool) -> Color {
        if isActive { return AppColor.accentYellow.opacity(0.4) }
        if filter == "Избранное" { return AppColor.accentYellow.opacity(0.15) }
        if filter == "Live" { return AppColor.liveRed.opacity(0.15) }
        return Color.white.opacity(0.06)
    }
}
