import Foundation

struct Zone: Identifiable, Codable {
    let id: UUID
    let name: String
    let iconName: String // SF Symbols
    let color: String
}
