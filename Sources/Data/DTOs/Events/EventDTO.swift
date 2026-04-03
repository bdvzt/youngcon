//
//  EventDTO.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

struct EventDTO: Decodable {
    let id: UUID
    let title: String?
    let description: String?
    let startDateTime: Date
    let endDateTime: Date
    let category: String?
    let zoneId: UUID
    let festivalId: UUID
}
