import Foundation
import SwiftUI

struct Achievement: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: URL?
    let color: Color
}
