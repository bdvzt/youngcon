import SwiftUI

struct ScannerView: View {
    let achievement: Achievement
    let organizerRepository: OrganizerRepositoryProtocol

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ScannerViewModel

    init(achievement: Achievement, organizerRepository: OrganizerRepositoryProtocol) {
        self.achievement = achievement
        self.organizerRepository = organizerRepository
        _vm = StateObject(wrappedValue: ScannerViewModel(achievement: achievement, organizerRepository: organizerRepository))
    }

    var body: some View {
        ZStack {
            if case .idle = vm.state {
                QRScannerRepresentable { code in vm.handle(qrCode: code) }.ignoresSafeArea()
            } else {
                AppColor.appBackground.ignoresSafeArea()
                Circle()
                    .fill(AppColor.accentPurple)
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .opacity(0.2)
            }

            VStack(spacing: 0) {
                topBar
                Spacer()
                centerContent
                Spacer()
                bottomBar
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(achievement.color)
                        .frame(width: 28, height: 28)

                    if let iconURL = achievement.icon {
                        AsyncImage(url: iconURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 14, height: 14)
                        .foregroundColor(.black)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                Text(achievement.name)
                    .font(AppFont.geo(12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(achievement.color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(achievement.color.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    @ViewBuilder
    private var centerContent: some View {
        switch vm.state {
        case .idle: idleContentView
        case .loading: loadingView
        case let .success(result, user):
            ScanResultView(
                achievement: achievement,
                result: result,
                user: user,
                onScanNext: { vm.reset() },
                onDone: { dismiss() }
            )
        case let .error(message): errorView(message)
        }
    }

    private var idleContentView: some View {
        VStack(spacing: 32) {
            scanFrame.frame(width: 240, height: 240)
            Text("Наведите камеру на QR-код участника")
                .font(AppFont.geo(14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scanFrame: some View {
        ZStack {
            ScannerCorner().frame(width: 40, height: 40).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            ScannerCorner().rotationEffect(.degrees(90)).frame(width: 40, height: 40).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            ScannerCorner().rotationEffect(.degrees(180)).frame(width: 40, height: 40).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            ScannerCorner().rotationEffect(.degrees(270)).frame(width: 40, height: 40).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView().progressViewStyle(.circular).tint(AppColor.accentYellow).scaleEffect(1.4)
            Text("Проверяем QR...").font(AppFont.geo(14, weight: .semibold)).foregroundColor(.white.opacity(0.4))
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill").font(.system(size: 36)).foregroundColor(AppColor.accentPink)
            Text("Ошибка").font(AppFont.geo(20, weight: .black)).foregroundColor(.white)
            Text(message).font(AppFont.geo(14)).foregroundColor(.white.opacity(0.4)).multilineTextAlignment(.center).padding(.horizontal, 40)
            Button { vm.reset() } label: {
                Text("Попробовать снова").font(AppFont.geo(14, weight: .bold)).foregroundColor(.black)
                    .padding(.horizontal, 28).padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(AppColor.accentYellow))
            }
            .buttonStyle(.plain)
        }
    }

    private var bottomBar: some View {
        Text("Организатор · YoungCon 2026")
            .font(AppFont.geo(11, weight: .semibold))
            .tracking(0.5).textCase(.uppercase)
            .foregroundColor(.white.opacity(0.15))
            .padding(.bottom, 40)
    }
}
