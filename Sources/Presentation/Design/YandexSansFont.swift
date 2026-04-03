import SwiftUI
import UIKit

extension Font {
    /// Yandex Sans Text — подписи, время, спикер, зона.
    /// Сборка через `UIFont` + `UIFontMetrics`: иначе `Font.custom(..., relativeTo:)` часто не подхватывает нужное начертание TTF.
    static func yandexSansText(
        _ style: Font.TextStyle,
        weight: Font.Weight = .regular,
        monospacedDigits: Bool = false
    ) -> Font {
        let postScript = YandexSansFont.textPostScript(for: weight)
        let fullName = YandexSansFont.textFullName(for: weight)
        var font = Self.yandexUIFontBacked(style: style, postScript: postScript, fullName: fullName, fallbackWeight: weight)
        if monospacedDigits {
            font = font.monospacedDigit()
        }
        return font
    }

    /// Yandex Sans Display — крупные заголовки на карточке.
    static func yandexSansDisplay(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let postScript = YandexSansFont.displayPostScript(for: weight)
        let fullName = YandexSansFont.displayFullName(for: weight)
        return Self.yandexUIFontBacked(style: style, postScript: postScript, fullName: fullName, fallbackWeight: weight)
    }

    private static func yandexUIFontBacked(
        style: Font.TextStyle,
        postScript: String,
        fullName: String,
        fallbackWeight: Font.Weight
    ) -> Font {
        let uiStyle = style.uiTextStyle
        let pointSize = UIFont.preferredFont(forTextStyle: uiStyle).pointSize
        let base = UIFont(name: postScript, size: pointSize) ?? UIFont(name: fullName, size: pointSize)
        guard let base else {
            return .system(size: pointSize, weight: fallbackWeight)
        }
        let scaled = UIFontMetrics(forTextStyle: uiStyle).scaledFont(for: base)
        return Font(scaled)
    }
}

private enum YandexSansFont {
    static func textPostScript(for weight: Font.Weight) -> String {
        if weight == .ultraLight || weight == .thin { return "YandexSansText-Thin" }
        if weight == .light { return "YandexSansText-Light" }
        if weight == .regular { return "YandexSansText-Regular" }
        if weight == .medium || weight == .semibold { return "YandexSansText-Medium" }
        if weight == .bold || weight == .heavy || weight == .black { return "YandexSansText-Bold" }
        return "YandexSansText-Regular"
    }

    static func textFullName(for weight: Font.Weight) -> String {
        if weight == .ultraLight || weight == .thin { return "Yandex Sans Text Thin" }
        if weight == .light { return "Yandex Sans Text Light" }
        if weight == .regular { return "Yandex Sans Text Regular" }
        if weight == .medium || weight == .semibold { return "Yandex Sans Text Medium" }
        if weight == .bold || weight == .heavy || weight == .black { return "Yandex Sans Text Bold" }
        return "Yandex Sans Text Regular"
    }

    static func displayPostScript(for weight: Font.Weight) -> String {
        if weight == .ultraLight || weight == .thin { return "YandexSansDisplay-Thin" }
        if weight == .light { return "YandexSansDisplay-Light" }
        if weight == .regular || weight == .medium { return "YandexSansDisplay-Regular" }
        if weight == .semibold || weight == .bold || weight == .heavy || weight == .black { return "YandexSansDisplay-Bold" }
        return "YandexSansDisplay-Regular"
    }

    static func displayFullName(for weight: Font.Weight) -> String {
        if weight == .ultraLight || weight == .thin { return "Yandex Sans Display Thin" }
        if weight == .light { return "Yandex Sans Display Light" }
        if weight == .regular || weight == .medium { return "Yandex Sans Display Regular" }
        if weight == .semibold || weight == .bold || weight == .heavy || weight == .black { return "Yandex Sans Display Bold" }
        return "Yandex Sans Display Regular"
    }
}

private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
    }
}
