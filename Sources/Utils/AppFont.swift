import SwiftUI
import UIKit

enum AppFont {
    enum GeoWeight: CaseIterable {
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black

        fileprivate var postScriptName: String {
            switch self {
            case .thin:
                "YSGeo-Thin"
            case .light:
                "YSGeo-Light"
            case .regular:
                "YSGeo-Regular"
            case .medium:
                "YSGeo-Medium"
            case .semibold:
                "YSGeo-Bold"
            case .bold:
                "YSGeo-Bold"
            case .heavy:
                "YSGeo-Heavy"
            case .black:
                "YSGeo-Black"
            }
        }

        fileprivate var fallbackWeight: UIFont.Weight {
            switch self {
            case .thin:
                .thin
            case .light:
                .light
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            case .bold:
                .bold
            case .heavy:
                .heavy
            case .black:
                .black
            }
        }

        fileprivate var swiftUIWeight: Font.Weight {
            switch self {
            case .thin:
                .thin
            case .light:
                .light
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            case .bold:
                .bold
            case .heavy:
                .heavy
            case .black:
                .black
            }
        }

        fileprivate var convertible: YoungConFontConvertible {
            switch self {
            case .thin:
                YoungConFontFamily.YSGeo.thin
            case .light:
                YoungConFontFamily.YSGeo.light
            case .regular:
                YoungConFontFamily.YSGeo.regular
            case .medium:
                YoungConFontFamily.YSGeo.medium
            case .semibold:
                YoungConFontFamily.YSGeo.bold
            case .bold:
                YoungConFontFamily.YSGeo.bold
            case .heavy:
                YoungConFontFamily.YSGeo.heavy
            case .black:
                YoungConFontFamily.YSGeo.black
            }
        }
    }

    private static let registeredFonts: Void = {
        YoungConFontFamily.registerAllCustomFonts()
    }()

    private static func ensureFontsRegistered() {
        _ = registeredFonts
    }

    static func geo(_ size: CGFloat, weight: GeoWeight = .regular) -> Font {
        ensureFontsRegistered()
        if let font = UIFont(font: weight.convertible, size: size) {
            return Font(font)
        }
        return .system(size: size, weight: weight.swiftUIWeight)
    }

    static func geo(_ size: CGFloat, weight: GeoWeight = .regular, relativeTo textStyle: Font.TextStyle) -> Font {
        ensureFontsRegistered()
        return .custom(weight.postScriptName, size: size, relativeTo: textStyle)
    }

    static func jersey(_ size: CGFloat) -> Font {
        ensureFontsRegistered()
        if let font = UIFont(font: YoungConFontFamily.Jersey10.regular, size: size) {
            return Font(font)
        }
        return .system(size: size)
    }

    static func jersey(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        ensureFontsRegistered()
        return .custom("Jersey10-Regular", size: size, relativeTo: textStyle)
    }

    static func uiGeo(_ size: CGFloat, weight: GeoWeight = .regular) -> UIFont {
        ensureFontsRegistered()
        return UIFont(font: weight.convertible, size: size) ?? .systemFont(ofSize: size, weight: weight.fallbackWeight)
    }

    static func uiJersey(_ size: CGFloat) -> UIFont {
        ensureFontsRegistered()
        return UIFont(font: YoungConFontFamily.Jersey10.regular, size: size) ?? .systemFont(ofSize: size)
    }

    static func validateRegistration() {
        #if DEBUG
            ensureFontsRegistered()
            let missingGeoFonts = GeoWeight.allCases.filter { UIFont(font: $0.convertible, size: 12) == nil }
                .map(\.postScriptName)
            let jerseyMissing = UIFont(font: YoungConFontFamily.Jersey10.regular, size: 12) == nil
            let missingFonts = missingGeoFonts + (jerseyMissing ? ["Jersey10-Regular"] : [])
            assert(missingFonts.isEmpty, "Missing custom fonts: \(missingFonts.joined(separator: ", "))")
        #endif
    }
}
