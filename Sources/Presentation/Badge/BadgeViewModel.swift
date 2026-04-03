import Combine
import Foundation

@MainActor
final class BadgeViewModel: ObservableObject {
    @Published private(set) var screenTitle: String = "Бейдж"

    // TODO: UsersRepository (GET /api/users/myself, /api/users/myself/qr, achievements, liked events)
    // TODO: роль (гость / staff) для скрытия staff-only экранов

    init() {}

    func onAppear() async {
        // TODO: профиль и ачивки текущего пользователя
    }
}
