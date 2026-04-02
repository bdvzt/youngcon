import Foundation

struct Achievement: Identifiable, Codeble {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let color: String
}
