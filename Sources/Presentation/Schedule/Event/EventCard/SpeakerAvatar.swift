import SwiftUI

struct SpeakerAvatar: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(EventCardPalette.speakerAvatar.opacity(0.55), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            EventCardPalette.speakerAvatar.opacity(0.35)
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
