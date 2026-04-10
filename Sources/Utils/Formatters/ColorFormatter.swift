import SwiftUI

extension Color {
    init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&int) else {
            return nil
        }

        let alpha, red, green, blue: UInt64
        switch hexSanitized.count {
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    static func from(hex: String, defaultValue: Color = .gray) -> Color {
        Color(hex: hex) ?? defaultValue
    }
}

extension String {
    func toColor(defaultValue: Color = .gray) -> Color {
        if let color = Color(hex: self) {
            return color
        }

        switch lowercased() {
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "orange":
            return .orange
        case "purple": return .purple
        case "pink":
            return .pink
        case "black":
            return .black
        case "white":
            return .white
        case "gray", "grey":
            return .gray
        default:
            return defaultValue
        }
    }
}
