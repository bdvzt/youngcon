import SwiftUI

struct ScanResultView: View {
    let achievement: Achievement
    let result: AssignResult
    let user: ResolvedUser
    let onScanNext: () -> Void
    let onDone: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                Circle()
                    .fill(achievement.color)
                    .frame(width: 72, height: 72)
                    .shadow(color: achievement.color.opacity(0.5), radius: 20)

                if let iconURL = achievement.icon {
                    AsyncImage(url: iconURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 32, height: 32)
                    .foregroundColor(.black)
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .padding(.bottom, 20)

            HStack(spacing: 6) {
                Image(systemName: result.assignedNow ? "checkmark.circle.fill" : "clock.fill")
                    .font(.system(size: 12))
                Text(result.assignedNow ? "Выдано впервые" : "Уже была выдана")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5).textCase(.uppercase)
            }
            .foregroundColor(
                result.assignedNow ? AppColor.accentYellow : .white.opacity(0.4)
            )
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(result.assignedNow
                        ? AppColor.accentYellow.opacity(0.1)
                        : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(result.assignedNow
                                ? AppColor.accentYellow.opacity(0.2)
                                : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)

            Text(achievement.name)
                .font(.system(size: 26, weight: .black))
                .tracking(-0.5).textCase(.uppercase)
                .foregroundColor(.white)
                .padding(.bottom, 6)
                .opacity(appeared ? 1 : 0)

            Text("\(user.firstName) \(user.lastName)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 32)
                .opacity(appeared ? 1 : 0)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(achievement.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(achievement.color.opacity(0.2), lineWidth: 1)
                        )
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(achievement.color.opacity(0.6))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(user.qrCode)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.25))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 10) {
                Button(action: onScanNext) {
                    HStack(spacing: 8) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 15, weight: .bold))
                        Text("Следующий участник")
                            .font(.system(size: 14, weight: .black))
                            .tracking(0.3).textCase(.uppercase)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.accentYellow)
                            .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 16)
                    )
                }
                .buttonStyle(.plain)

                Button(action: onDone) {
                    Text("Готово")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}
