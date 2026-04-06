import SwiftUI

// MARK: - Mocks

let example = Speaker(
    id: "",
    fullName: "Анна Иванова",
    job: "Директор по продукту, Яндекс",
    bio: """
    Лидеры направлений, визионеры и создатели ключевых продуктов. 
    Они задают тренды в индустрии, формируют вектор развития технологий 
    и знают, как построить сервисы, которыми будут пользоваться 
    миллионы людей каждый день.
    """,
    avatarURL: ""
)

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
        YoungConAsset.appBackground.swiftUIColor
            .ignoresSafeArea()
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            GeometryReader { geometry in
                cardContainer
                    .frame(height: geometry.size.height / 1.6)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }

            Spacer()
        }
    }

    // MARK: - Card Container

    private var cardContainer: some View {
        VStack(spacing: 0) {
            topNavigationBar
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
                .background(AppColor.cardBackground)

            scrollableContent
        }
        .background(AppColor.cardBackground.preferredColorScheme(.dark))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 42)
                .stroke(whiteText.opacity(0.2), lineWidth: 1.0)
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
                        .font(.system(size: 16, weight: .heavy))
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
            Text("ТОП-МЕНЕДЖМЕНТ")
                .font(.system(size: 32, weight: .heavy))
            Text("ЯНДЕКСА")
                .font(.system(size: 32, weight: .heavy))
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
            .font(.system(size: 14, weight: .bold))
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
            .font(.system(size: 13, weight: .heavy))
            .foregroundColor(whiteText.opacity(0.5))
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(whiteText.opacity(0.15))
            .frame(height: 1)
    }

    private var aboutSpeakerText: some View {
        Text(speaker.bio)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(whiteText.opacity(0.85))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Ask Question Button

    private var askQuestionButton: some View {
        Button(
            action: { print("Задать вопрос спикеру: \(speaker.fullName)") },
            label: {
                Text("вопрос спикеру")
                    .font(.system(size: 16, weight: .heavy))
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
        if let photoURLString = speaker.avatarURL, !photoURLString.isEmpty,
           let photoURL = URL(string: photoURLString)
        {
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
            .foregroundColor(whiteText.opacity(speaker.avatarURL == nil ? 0.3 : 0.5))
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

// MARK: - Preview

#Preview {
    SpeakerCardView(speaker: example)
}
