//
//  EventsRepositoryProtocol.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

protocol EventsRepositoryProtocol: AnyObject {
    func fetchEvent(id: UUID) async throws -> Event
    func fetchEvents(festivalId: UUID) async throws -> [Event]
    func fetchEventSpeakers(eventID: UUID) async throws -> [Speaker]
    func fetchEventDetails(id: UUID) async throws -> (event: Event, speaker: [Speaker])
    @discardableResult
    func toggleLike(eventId: UUID) async throws -> Bool
}
