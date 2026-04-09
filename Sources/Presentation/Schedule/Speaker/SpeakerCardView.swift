import SwiftUI

// MARK: - SpeakerCardView

struct SpeakerCardView: View {
    // MARK: - Properties

    let speaker: Speaker
    @Environment(\.dismiss) private var dismiss

    // MARK: - Colors

    private let whiteText = Color.white

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .navigationBarHidden(true)
    }

    // MARK: - Background

    private var backgroundView: some View {
        AppColor.navBackground
            .ignoresSafeArea()
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                cardContainer
                    .frame(height: geometry.size.height / 1.5)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }

    // MARK: - Card Container

    private var cardContainer: some View {
        VStack(spacing: 0) {
            topNavigationBar
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
                .background(AppColor.navBackground)

            scrollableContent
        }
        .background(AppColor.navBackground.preferredColorScheme(.dark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(whiteText.opacity(0.05), lineWidth: 1.0)
        )
    }

    // MARK: - Top Navigation Bar

    private var topNavigationBar: some View {
        HStack {
            backButton
            Spacer()
            closeButton
        }
    }

    private var backButton: some View {
        Button(
            action: { dismiss() },
            label: {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("К СОБЫТИЮ")
                        .font(AppFont.geo(16, weight: .heavy))
                }
                .foregroundColor(whiteText.opacity(0.6))
            }
        )
    }

    private var closeButton: some View {
        Button(
            action: { dismiss() },
            label: {
                ZStack {
                    Circle()
                        .fill(whiteText.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(whiteText.opacity(0.6))
                }
            }
        )
    }

    // MARK: - Scrollable Content

    private var scrollableContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                avatarSection
                titleSection
                speakersTagSection
                aboutSpeakerSection
                askQuestionButton
            }
        }
        .scrollIndicators(.visible)
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        avatarView
            .padding(.leading, 28)
            .padding(.top, 20)
            .padding(.bottom, 20)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(speaker.fullName.uppercased())
                .font(AppFont.geo(32, weight: .heavy))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(whiteText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.bottom, 8)
    }

    // MARK: - Speakers Tag Section

    private var speakersTagSection: some View {
        HStack {
            speakersTag
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
    }

    private var speakersTag: some View {
        Text("Ключевые спикеры")
            .font(AppFont.geo(14, weight: .bold))
            .foregroundColor(YoungConAsset.accentYellow.swiftUIColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(YoungConAsset.navBackground.swiftUIColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(whiteText.opacity(0.2), lineWidth: 1.0)
            )
    }

    // MARK: - About Speaker Section

    private var aboutSpeakerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            aboutSpeakerTitle
            separatorLine
            aboutSpeakerText
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
    }

    private var aboutSpeakerTitle: some View {
        Text("О СПИКЕРЕ")
            .font(AppFont.geo(13, weight: .heavy))
            .foregroundColor(whiteText.opacity(0.5))
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(whiteText.opacity(0.15))
            .frame(height: 1)
    }

    private var aboutSpeakerText: some View {
        Text(speaker.bio)
            .font(AppFont.geo(14, weight: .semibold))
            .foregroundColor(whiteText.opacity(0.85))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Ask Question Button

    private var askQuestionButton: some View {
        Button(
            action: {
                guard let url = URL(string: "https://forms.yandex.ru/u/69d62952d046880434747b3f") else {
                    print("❌ Не удалось создать URL для Яндекс Формы")
                    return
                }
                UIApplication.shared.open(url)
            },
            label: {
                Text("вопрос спикеру")
                    .font(AppFont.geo(16, weight: .heavy))
                    .foregroundColor(AppColor.cardBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(whiteText)
                    )
            }
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 32)
    }

    // MARK: - Avatar View

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            speakerAvatarImage
            starBadge
        }
    }

    @ViewBuilder
    private var speakerAvatarImage: some View {
        if let photoURL = speaker.avatarImageURL {
            AsyncImage(url: photoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                avatarPlaceholder
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
        } else {
            avatarPlaceholder
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(whiteText.opacity(0.3), lineWidth: 1.0)
                )
        }
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundColor(whiteText.opacity(speaker.avatarImageURL == nil ? 0.3 : 0.5))
    }

    private var starBadge: some View {
        ZStack {
            Circle()
                .fill(YoungConAsset.accentYellow.swiftUIColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(AppColor.cardBackground, lineWidth: 4.0)
                )

            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColor.cardBackground)
        }
        .offset(x: 4, y: 4)
    }
}
