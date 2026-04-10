import SwiftUI

struct AchievementTile: View {
    let achievement: Achievement
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(achievement.color.opacity(isSelected ? 1 : 0.18))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? achievement.color : Color.white.opacity(0.08),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isSelected ? achievement.color.opacity(0.5) : .clear,
                            radius: 14
                        )

                    if let iconURL = achievement.icon {
                        AsyncImage(url: iconURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(isSelected ? .black : achievement.color.opacity(0.7))
                        }
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? .black : achievement.color.opacity(0.7))
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isSelected ? .black : achievement.color.opacity(0.7))
                    }
                }
                Text(achievement.name)
                    .font(AppFont.geo(9, weight: .bold))
                    .tracking(0.3)
                    .textCase(.uppercase)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? achievement.color.opacity(0.08) : Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? achievement.color.opacity(0.3) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
