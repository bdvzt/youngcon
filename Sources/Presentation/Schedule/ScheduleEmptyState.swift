import SwiftUI

struct ScheduleEmptyState: View {
    let activeFilter: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: activeFilter == "Избранное" ? "star" : "calendar")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.06))

            Text(activeFilter == "Избранное" ? "Нажмите ★ чтобы добавить" : "Ничего не найдено")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.01))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )
        )
        .padding(.top, 8)
    }
}
