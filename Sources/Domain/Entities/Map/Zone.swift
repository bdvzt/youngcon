import SwiftUI

struct Zone: Identifiable {
    let id: String
    let floorID: String
    let title: String
    let description: String
    let cordX: Double?
    let cordY: Double?
    let icon: URL
    let color: Color
}
