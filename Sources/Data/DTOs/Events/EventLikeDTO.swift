//
//  EventLikeDTO.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

struct EventLikeDTO: Decodable {
    let eventId: UUID
    let userId: UUID
    let isLiked: Bool
}
