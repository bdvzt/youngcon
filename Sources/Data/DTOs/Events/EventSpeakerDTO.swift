//
//  EventSpeakerDTO.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

struct EventSpeakerDTO: Decodable {
    let id: UUID
    let fullName: String?
    let job: String?
    let avatarURL: String?
}
