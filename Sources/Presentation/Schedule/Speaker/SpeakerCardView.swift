import SwiftUI

let example = Speaker(
    id: UUID(),
    name: "Анна Иванова",
    role: "Директор по продукту, Яндекс",
    bio: "Лидеры направлений, визионеры и создатели ключевых продуктов. Они задают тренды в индустрии, формируют вектор развития технологий и знают, как построить сервисы, которыми будут пользоваться миллионы людей каждый день.",
    photoURL: nil
)

struct SpeakerCardView: View {
    // MARK: - Properties
    let speaker: Speaker
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Colors
    private let whiteText = Color.white
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    TopNavigationBar()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                        .background(Color("CardBackgound"))
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            AvatarView()
                                .padding(.leading, 28)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ТОП-МЕНЕДЖМЕНТ")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(whiteText)
                                Text("ЯНДЕКСА")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(whiteText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                            .padding(.bottom, 8)
                            
                            HStack {
                                Text("Ключевые спикеры")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color("AccentYellow"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("NavBackground"))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(whiteText.opacity(0.2), lineWidth: 1.0)
                                    )
                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.bottom, 32)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("О СПИКЕРЕ")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundColor(whiteText.opacity(0.5))
                                
                                Rectangle()
                                    .fill(whiteText.opacity(0.15))
                                    .frame(height: 1)
                                
                                Text(speaker.bio)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(whiteText.opacity(0.85))
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 28)
                            .padding(.bottom, 32)
                            
                            Button(action: {
                                print("Задать вопрос спикеру: \(speaker.name)")
                            }) {
                                Text("вопрос спикеру")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(Color("CardBackground"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(whiteText)
                                    )
                            }
                            .padding(.horizontal, 28)
                            .padding(.bottom, 32)
                        }
                    }
                    .scrollIndicators(.visible)
                }
                .frame(height: UIScreen.main.bounds.height / 1.9)
                .background(Color("CardBackground").preferredColorScheme(.dark))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 42)
                        .stroke(whiteText.opacity(0.2), lineWidth: 1.0)
                )
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Top Navigation Bar
    @ViewBuilder
    private func TopNavigationBar() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(whiteText.opacity(0.6))
                    Text("К СОБЫТИЮ")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(whiteText.opacity(0.6))
                }
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(whiteText.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(whiteText.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Avatar View
    @ViewBuilder
    private func AvatarView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let photoURL = speaker.photoURL {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(whiteText.opacity(0.5))
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(whiteText.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(whiteText.opacity(0.3), lineWidth: 1.0))
            }
            
            ZStack {
                Circle()
                    .fill(Color("AccentYellow"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color("CardBackground"), lineWidth: 4.0)
                    )
                
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("CardBackground"))
            }
            .offset(x: 4, y: 4)
        }
    }
}

// MARK: - Preview
#Preview {
    SpeakerCardView(speaker: example)
}
