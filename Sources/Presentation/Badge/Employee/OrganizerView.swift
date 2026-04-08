import SwiftUI

struct OrganizerView: View {
    let container: DependencyContainer
    @ObservedObject var appViewModel: AppViewModel
    var onLogout: (() -> Void)?

    @StateObject private var viewModel: OrganizerViewModel
    @State private var selectedAchievement: Achievement? = nil
    @State private var showScanner = false
    @State private var gradientOffset: CGFloat = 0

    init(container: DependencyContainer, appViewModel: AppViewModel, onLogout: (() -> Void)? = nil) {
        self.container = container
        self.appViewModel = appViewModel
        self.onLogout = onLogout
        _viewModel = StateObject(wrappedValue: OrganizerViewModel(
            achievementsRepository: container.achievementsRepository
        ))
    }

    var body: some View {
        guard appViewModel.profile?.role == .employee else {
            return AnyView(EmptyView())
        }

        return AnyView(
            ZStack(alignment: .topLeading) {
                Color.clear

                VStack(spacing: 0) {
                    Color.clear.frame(height: 52)
                    headerSection

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            if let a = selectedAchievement { selectedBanner(a) }

                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(AppColor.accentYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                            } else if let loadingError = viewModel.loadingError {
                                Text(loadingError)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.55))
                                    .multilineTextAlignment(.center)
                            }

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                                spacing: 12
                            ) {
                                ForEach(viewModel.achievements) { achievement in
                                    AchievementTile(
                                        achievement: achievement,
                                        isSelected: selectedAchievement?.id == achievement.id
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAchievement = selectedAchievement?.id == achievement.id
                                                ? nil
                                                : achievement
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 180)
                    }
                }

                VStack(spacing: 0) {
                    AppColor.appBackground.ignoresSafeArea(edges: .top)
                        .frame(height: 0)
                    AppColor.appBackground.frame(height: 52)
                    LinearGradient(
                        colors: [AppColor.appBackground, AppColor.appBackground.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 32)
                    Spacer()
                }
                .zIndex(20)
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(RadialGradient(
                                    colors: [AppColor.accentYellow, .clear],
                                    center: .center, startRadius: 5, endRadius: 40
                                ))
                                .frame(width: 80, height: 60)
                                .blur(radius: 20)
                                .opacity(0.35)

                            YoungConAsset.logo.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(height: 36)
                                .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .allowsHitTesting(false)

                        Spacer()

                        Button {
                            onLogout?()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Выйти")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .background(Capsule().fill(Color.white.opacity(0.05)))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer()
                }
                .zIndex(21)

                VStack {
                    Spacer()
                    scanButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                }
                .zIndex(22)
            }
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                    gradientOffset = 1
                }
                if viewModel.achievements.isEmpty { viewModel.loadAchievements() }
            }
            .fullScreenCover(isPresented: $showScanner) {
                if let achievement = selectedAchievement {
                    ScannerView(
                        achievement: achievement,
                        organizerRepository: container.organizerRepository
                    )
                }
            }
        )
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Выдать\nачивку")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .allowsTightening(true)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColor.accentYellow,
                            AppColor.accentPurple,
                            AppColor.accentPink,
                            AppColor.accentYellow,
                        ],
                        startPoint: UnitPoint(x: gradientOffset * 0.5, y: 0),
                        endPoint: UnitPoint(x: gradientOffset * 0.5 + 1, y: 1)
                    )
                )

            Text("Выберите ачивку, которую будете раздавать")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 12)
    }

    private func selectedBanner(_ a: Achievement) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(a.color).frame(width: 44, height: 44)
                if let iconURL = a.icon {
                    AsyncImage(url: iconURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Выбрано")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(.white.opacity(0.3))
                Text(a.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(a.color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(a.color.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(a.color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var scanButton: some View {
        Button {
            guard appViewModel.profile?.role == .employee else { return }
            showScanner = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 18, weight: .bold))
                Text("Сканировать QR")
                    .font(.system(size: 15, weight: .black))
                    .tracking(0.5)
                    .textCase(.uppercase)
            }
            .foregroundColor(selectedAchievement != nil ? .black : .white.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if selectedAchievement != nil {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColor.accentYellow)
                            .shadow(color: AppColor.accentYellow.opacity(0.35), radius: 20)
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.06))
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedAchievement == nil)
    }
}
