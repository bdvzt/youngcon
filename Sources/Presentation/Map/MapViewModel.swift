import Combine
import Foundation

@MainActor
final class MapViewModel: ObservableObject {
    @Published private(set) var screenTitle: String = "Карта"

    // TODO: FloorsRepository, ZonesRepository; выбранный этаж; список зон для этажа

    init() {}

    func onAppear() async {
        // TODO: GET /api/floors, /api/zones или /api/zones/by-floor/{floorId}
    }
}
