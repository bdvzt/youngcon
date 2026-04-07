import Foundation
import Kingfisher
import SwiftUI

struct LocationPinView: View {
    let zone: Zone
    let isFocused: Bool
    let focusedZoneID: String?
    let background: Color
    let yellow: Color
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            pinIcon
            if !isFocused { pinLabel }
        }
        .opacity(focusedZoneID != nil && !isFocused ? 0.5 : 1)
        .onTapGesture { onTap() }
    }

    private var pinIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(zone.color)
                .frame(width: 36, height: 36)
                .overlay(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused ? yellow : Color.white.opacity(0.25),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                .shadow(color: isFocused ? yellow.opacity(0.4) : .clear, radius: 14)

            ZoneIconImage(url: zone.icon, placeholderFontSize: 14)
                .frame(width: 18, height: 18)
        }
        .scaleEffect(isFocused ? 1.1 : (focusedZoneID != nil ? 0.85 : 1.0))
    }

    private var pinLabel: some View {
        Text(zone.title.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(background.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
    }
}

struct ZoneIconImage: View {
    let url: URL
    let placeholderFontSize: CGFloat

    var body: some View {
        image
            .placeholder {
                placeholder()
            }
            .onFailureView {
                placeholder()
            }
            .resizable()
            .scaledToFit()
    }

    private var image: KFImage {
        if YandexDiskImageDataProvider.canHandle(url) {
            // Public Yandex Disk pages return HTML/captcha to image loaders, so resolve them to files first.
            return KFImage.dataProvider(YandexDiskImageDataProvider(publicURL: url))
        }

        return KFImage(url)
    }

    private func placeholder() -> some View {
        Image(systemName: "mappin.fill")
            .font(.system(size: placeholderFontSize, weight: .semibold))
            .foregroundColor(.black)
    }
}

private struct YandexDiskImageDataProvider: ImageDataProvider {
    enum ProviderError: Error {
        case invalidResolveURL
        case invalidDownloadURL
        case emptyResponse
    }

    let publicURL: URL

    var cacheKey: String {
        publicURL.absoluteString
    }

    var contentURL: URL? {
        publicURL
    }

    static func canHandle(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host == "disk.yandex.ru" || host == "yadi.sk"
    }

    func data(handler: @escaping @Sendable (Result<Data, any Error>) -> Void) {
        guard let resolveURL = makeResolveURL() else {
            handler(.failure(ProviderError.invalidResolveURL))
            return
        }

        URLSession.shared.dataTask(with: resolveURL) { data, _, error in
            if let error {
                handler(.failure(error))
                return
            }

            guard let data else {
                handler(.failure(ProviderError.emptyResponse))
                return
            }

            do {
                let response = try JSONDecoder().decode(YandexDiskDownloadResponse.self, from: data)
                guard let downloadURL = URL(string: response.href) else {
                    handler(.failure(ProviderError.invalidDownloadURL))
                    return
                }

                URLSession.shared.dataTask(with: downloadURL) { imageData, _, error in
                    if let error {
                        handler(.failure(error))
                        return
                    }

                    guard let imageData else {
                        handler(.failure(ProviderError.emptyResponse))
                        return
                    }

                    handler(.success(imageData))
                }
                .resume()
            } catch {
                handler(.failure(error))
            }
        }
        .resume()
    }

    private func makeResolveURL() -> URL? {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/public/resources/download")
        components?.queryItems = [
            URLQueryItem(name: "public_key", value: publicURL.absoluteString),
        ]
        return components?.url
    }
}

private struct YandexDiskDownloadResponse: Decodable {
    let href: String
}
