import Foundation
import SwiftUI
@testable import YoungCon

enum MapViewModelTestFactory {
    static func makeFloor(id: String, title: String) -> Floor {
        Floor(
            id: id,
            title: title,
            mapImageURL: URL(string: "https://example.com/\(id).png")!
        )
    }

    static func makeZone(id: String, floorID: String, title: String) -> Zone {
        Zone(
            id: id,
            floorID: floorID,
            title: title,
            description: "\(title) description",
            cordX: 0.5,
            cordY: 0.5,
            icon: URL(string: "https://example.com/\(id).png")!,
            color: .blue
        )
    }
}
