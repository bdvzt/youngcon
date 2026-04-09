import Kingfisher
import SwiftUI

struct SpeakerAvatar: View {
    let url: URL?
    let fullName: String

    var body: some View {
        Group {
            if let url {
                KFImage(url)
                    .placeholder { placeholder }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(AppColor.gray700.opacity(0.55), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            AppColor.gray700.opacity(0.35)
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var initials: String {
        let parts = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        if parts.isEmpty { return "?" }
        return String(parts)
    }
}
