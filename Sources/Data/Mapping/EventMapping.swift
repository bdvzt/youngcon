//
//  EventMapping.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 03.04.2026.
//

import Foundation

enum EventMapping {
    static func domain(from dto: EventDTO, speakersId: [UUID] = [], streamURL: URL? = nil) -> Event {
        Event(
            id: dto.id,
              title: dto.title ?? "",
              start: dto.startDateTime,
              end: dto.endDateTime,
              speakerIDs: speakersId,
              zoneID: dto.zoneId,
              categoryCode: dto.category ?? "",
              streamURL: streamURL
        )
    }
}

extension Speaker {
    init(eventSpeaker dto: EventSpeakerDTO) {
        self.init(
            id: dto.id,
            name: dto.fullName ?? "",
            role: dto.job ?? "",
            bio: "",
            photoURL: dto.avatarURL.flatMap(URL.init(string:))
        )
    }
}
