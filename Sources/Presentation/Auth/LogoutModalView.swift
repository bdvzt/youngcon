import SwiftUI

struct LogoutModalView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }

            VStack(spacing: 24) {
                Text("Выйти из аккаунта?")
                    .font(AppFont.geo(18, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Вы уверены, что хотите выйти из своего профиля?")
                    .font(AppFont.geo(14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button {
                        isPresented = false
                        onConfirm()
                    } label: {
                        Text("Выйти")
                            .font(AppFont.geo(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.8))
                            )
                    }

                    Button {
                        withAnimation { isPresented = false }
                    } label: {
                        Text("Отмена")
                            .font(AppFont.geo(16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .background(Capsule().fill(Color.white.opacity(0.05)))
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(AppColor.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColor.accentYellow.opacity(0.2),
                                        Color.clear,
                                        Color.clear,
                                        AppColor.accentPurple.opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}
