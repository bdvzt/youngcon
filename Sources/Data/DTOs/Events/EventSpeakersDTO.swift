//
//  EventSpeakersDTO.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

struct EventSpeakersDTO: Decodable {
    let eventId: UUID
    let speakers: [EventSpeakerDTO]?
}
