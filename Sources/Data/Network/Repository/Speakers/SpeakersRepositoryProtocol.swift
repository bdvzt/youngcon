protocol SpeakersRepositoryProtocol {
    func getSpeaker(speakerID: String, policy: CachePolicy) async throws -> Speaker
    func getAllSpeakers(policy: CachePolicy) async throws -> [Speaker]
}
