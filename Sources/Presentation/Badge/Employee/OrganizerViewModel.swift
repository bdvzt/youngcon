import Foundation
import SwiftUI

@MainActor
final class OrganizerViewModel: ObservableObject {
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var loadingError: String?

    private let achievementsRepository: AchievementsRepositoryProtocol
    private var pollingTask: Task<Void, Never>?

    init(achievementsRepository: AchievementsRepositoryProtocol) {
        self.achievementsRepository = achievementsRepository
    }

    func loadAchievements() async {
        await loadAchievements(policy: .cacheFirst, mode: .initial)
    }

    func refreshFromNetworkIfNeeded() async {
        await loadAchievements(policy: .networkFirst, mode: .refresh)
    }

    func startPolling(every seconds: TimeInterval = 60) {
        stopPolling()

        pollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                await refreshFromNetworkIfNeeded()

                do {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                } catch {
                    break
                }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func loadAchievements(
        policy: CachePolicy,
        mode: LoadMode
    ) async {
        guard !isLoading, !isRefreshing else { return }

        applyLoadingState(for: mode, isActive: true)
        defer { applyLoadingState(for: mode, isActive: false) }

        do {
            let items = try await achievementsRepository.getAchievements(policy: policy)
            let sortedItems = items.sorted { $0.name < $1.name }

            if sortedItems != achievements {
                achievements = sortedItems
            }

            loadingError = nil
        } catch {
            if achievements.isEmpty {
                loadingError = "Не удалось загрузить список ачивок"
            }
            print("Error loading achievements: \(error.localizedDescription)")
        }
    }

    private func applyLoadingState(for mode: LoadMode, isActive: Bool) {
        switch mode {
        case .initial:
            isLoading = isActive
        case .refresh:
            isRefreshing = isActive
        }
    }
}

private extension OrganizerViewModel {
    enum LoadMode {
        case initial
        case refresh
    }
}
