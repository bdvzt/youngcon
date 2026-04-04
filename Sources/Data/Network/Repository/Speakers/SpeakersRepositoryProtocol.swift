protocol SpeakersRepositoryProtocol {
    func getSpeaker(speakerID: String) async throws -> Speaker
    func getAllSpeakers() async throws -> [Speaker]
}
