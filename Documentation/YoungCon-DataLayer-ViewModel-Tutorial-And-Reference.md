# YoungCon: слой данных и ViewModel — руководство для команды

Документ описывает **как мы договариваемся строить фичи** (сеть, репозитории, ViewModel). Готовый **эталонный код** для фичи Events + `EventCard` — в [разделе 6](#6-эталонный-код-скопировать-в-проект-по-файлам); его можно переносить в репозиторий по файлам или использовать как подсказку при своей реализации.

---

## 1. Слои

| Слой | Папки (ориентир) | Ответственность |
|------|------------------|-----------------|
| **Domain** | `Sources/Domain/` | Сущности (`Event`, `Speaker` и т.д.), **протоколы** репозиториев. Без SwiftUI и без полей «как в JSON». |
| **Data** | `Sources/Data/` | DTO по Swagger, маппинг DTO → Domain, типы `EndPoint`, классы репозиториев, при необходимости общий `JSONEncoder`/`JSONDecoder` с политикой дат. |
| **Presentation** | `Sources/Presentation/` | SwiftUI, **ViewModel** (`ObservableObject` / `@MainActor` по договорённости), навигация. |

**NetworkCore** (`Sources/Data/NetworkCore/`) — транспорт: `EndPoint`, `URLRequestBuilder`, `NetworkService`, ошибки, `AuthorizationProvider`, keychain-протоколы. Новые эндпоинты обычно **не** лезут внутрь этих типов, а добавляют новые структуры, реализующие `EndPoint`.

---

## 2. Поток: Swagger → экран

1. В **OpenAPI** ([Swagger UI](http://213.165.218.183:8080/swagger/index.html), [swagger.json](http://213.165.218.183:8080/swagger/v1/swagger.json)) — путь, метод, схема тела и ответа.
2. **DTO** в Data: свойства совпадают с JSON (или через `CodingKeys`). Учесть `nullable` и формат дат (`date-time`).
3. **Маппер** в одном месте: DTO → доменная модель. Если в API нет поля, которое есть в Domain (например выдуманный пока `streamURL`), в маппере явно задаёте значение по умолчанию (`nil` и т.д.).
4. **Протокол репозитория** в Domain — методы уровня сценария: `fetch…`, `save…`, не «сырой HTTP».
5. **Реализация репозитория** в Data: собирает конкретный `EndPoint`, вызывает `NetworkServiceProtocol.request` / `requestDecodable`.
6. **ViewModel**: зависит от протокола репозитория; `@Published` / флаги загрузки; `async` для сети; превью — через mock/stub репозитория (`#if DEBUG`).
7. **View**: по возможности только отображение; `Task { await viewModel.… }` для действий; не импортировать `NetworkService` в View.

---

## 3. Чеклист: своя ViewModel и репозиторий

### A. Контракт API

- [ ] Маршруты и методы из Swagger.
- [ ] Нужен ли Bearer: для операции выставить `AuthorizationRequirement.accessToken` или `.none` на `EndPoint`.

### B. Data

- [ ] Файл(ы) DTO, `Decodable` / `Encodable` по необходимости.
- [ ] Единая стратегия дат: например общий `JSONDecoder` с `.iso8601` и тот же подход в `JSONEncoder` для тел запросов — имеет смысл завести **один** тип вроде `JSONCoding` и использовать его в `NetworkService` и `URLRequestBuilder`, когда дойдёте до реальных дат с бэка.
- [ ] Маппинг в доменные типы.

### C. Сеть

- [ ] Структуры с `EndPoint`: `baseURL` (например `APIConstants.baseURL`), `path` без дублирования префикса `/api`, `method`, `task`, `authorization`.
- [ ] Протокол репозитория + класс/actor реализации.

### D. ViewModel

- [ ] Явные входы в `init` (протоколы, id модели и т.д.).
- [ ] Состояние UI: данные, `isLoading`, при необходимости сообщение об ошибке (лучше, чем пустой `catch`).
- [ ] Превью изолированы от сети.

### E. View

- [ ] `@StateObject` там, где владеете VM; `@ObservedObject` у дочерних view, если VM создаёт родитель.
- [ ] После добавления файлов в `Sources/**` — **`tuist generate`**, чтобы Xcode подхватил файлы.

### F. NetworkCore (напоминание)

- [ ] `requestDecodable` сейчас использует «голый» `JSONDecoder()` — для дат с backend обычно **нужно** поменять стратегию в одном месте (см. п. B).
- [ ] Ошибки: `NetworkError`, в т.ч. `unauthorized` для 401.

---

## 4. Типичные вопросы

- **Домен расходится со Swagger** — нормально; расхождение живёт только в маппере.
- **401 / нет токена** — договориться, показывать ли экран логина или алерт; `AuthorizationProvider` сейчас не падает, если токена нет, а просто не ставит заголовок.
- **Параллельные запросы** — `async let` / `withTaskGroup` в репозитории или use-case, не во View.

---

## 5. Пример порядка файлов для фичи «События» (ориентир по папкам)

Названия условные — вы выбираете свои, главное **порядок зависимостей**:

1. `Data/…/EventDTO.swift` (и соседние DTO из схем).
2. `Data/…/EventMapping.swift` (или `DTO+Domain.swift`).
3. `Domain/…/EventsRepositoryProtocol.swift`.
4. `Data/…/Endpoints/EventsEndpoints.swift` (несколько `struct …: EndPoint`).
5. `Data/…/EventsRepository.swift`.
6. Фабрика зависимостей (например `AppServices` или инициализация в `App`) — собрать `KeychainTokenStorage` → `AuthorizationProvider` → `NetworkService` → репозиторий.
7. `Presentation/…/EventCardViewModel.swift`.
8. Подключить VM в `EventCard` или родительский экран.

Этот список — **дорожная карта**, а не обязательная структура каталогов.

---

## 6. Эталонный код (скопировать в проект по файлам)

Ниже — **рабочий пример** цепочки: DTO по Swagger → маппинг → `EndPoint` → репозиторий → `EventCardViewModel` → `EventCard` с лайком.  
**Не** склеивайте всё в один `.swift`: в таргете получатся дубликаты типов.

Уже есть в репозитории: `APIConstants.baseURL`, `EndPoint`, `NetworkService`, keychain, доменные `Event` / `Speaker` / `Zone`.

### 6.1 `Sources/Data/Network/JSONCoding.swift`

```swift
import Foundation

enum JSONCoding {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
```

### 6.2 Правки NetworkCore (даты и тела JSON)

В **`NetworkService.swift`**, внутри `requestDecodable`, замените декодер:

```swift
return try JSONCoding.decoder.decode(T.self, from: data)
```

В **`URLRequestBuilder.swift`**, в ветке `requestBody`:

```swift
request.httpBody = try JSONCoding.encoder.encode(data)
```

### 6.3 `Sources/Data/DTOs/Events/EventDTO.swift`

```swift
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
```

### 6.4 `Sources/Data/DTOs/Events/EventSpeakerDTO.swift`

```swift
import Foundation

struct EventSpeakerDTO: Decodable {
    let id: UUID
    let fullName: String?
    let job: String?
    let avatarURL: String?
}
```

### 6.5 `Sources/Data/DTOs/Events/EventSpeakersDTO.swift`

```swift
import Foundation

struct EventSpeakersDTO: Decodable {
    let eventId: UUID
    let speakers: [EventSpeakerDTO]?
}
```

### 6.6 `Sources/Data/DTOs/Events/EventLikeDTO.swift`

```swift
import Foundation

struct EventLikeDTO: Decodable {
    let eventId: UUID
    let userId: UUID
    let isLiked: Bool
}
```

### 6.7 `Sources/Data/Mapping/EventMapping.swift`

```swift
import Foundation

enum EventMapping {
    static func domain(
        from dto: EventDTO,
        speakerIDs: [UUID] = [],
        streamURL: URL? = nil
    ) -> Event {
        Event(
            id: dto.id,
            title: dto.title ?? "",
            start: dto.startDateTime,
            end: dto.endDateTime,
            speakerIDs: speakerIDs,
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
```

### 6.8 `Sources/Domain/Repositories/EventsRepositoryProtocol.swift`

```swift
import Foundation

protocol EventsRepositoryProtocol: AnyObject {
    func fetchEvent(id: UUID) async throws -> Event
    func fetchEvents(festivalId: UUID) async throws -> [Event]
    func fetchEventSpeakers(eventId: UUID) async throws -> [Speaker]
    func fetchEventDetails(id: UUID) async throws -> (event: Event, speakers: [Speaker])
    @discardableResult
    func toggleLike(eventId: UUID) async throws -> Bool
}
```

### 6.9 `Sources/Data/Network/Endpoints/EventsEndpoints.swift`

```swift
import Foundation

struct GetEventEndpoint: EndPoint {
    let id: UUID
    var baseURL: URL { APIConstants.baseURL }
    var path: String { "events/\(id.uuidString)" }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}

struct GetEventsByFestivalEndpoint: EndPoint {
    let festivalId: UUID
    var baseURL: URL { APIConstants.baseURL }
    var path: String { "events/by-festival/\(festivalId.uuidString)" }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}

struct GetEventSpeakersEndpoint: EndPoint {
    let eventId: UUID
    var baseURL: URL { APIConstants.baseURL }
    var path: String { "events/\(eventId.uuidString)/speakers" }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}

struct PostEventLikeEndpoint: EndPoint {
    let eventId: UUID
    var baseURL: URL { APIConstants.baseURL }
    var path: String { "events/\(eventId.uuidString)/like" }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
```

### 6.10 `Sources/Data/Repositories/EventsRepository.swift`

```swift
import Foundation

final class EventsRepository: EventsRepositoryProtocol {
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol) {
        self.network = network
    }

    func fetchEvent(id: UUID) async throws -> Event {
        let dto: EventDTO = try await network.requestDecodable(
            GetEventEndpoint(id: id),
            as: EventDTO.self
        )
        return EventMapping.domain(from: dto)
    }

    func fetchEvents(festivalId: UUID) async throws -> [Event] {
        let dtos: [EventDTO] = try await network.requestDecodable(
            GetEventsByFestivalEndpoint(festivalId: festivalId),
            as: [EventDTO].self
        )
        return dtos.map { EventMapping.domain(from: $0) }
    }

    func fetchEventSpeakers(eventId: UUID) async throws -> [Speaker] {
        let dto: EventSpeakersDTO = try await network.requestDecodable(
            GetEventSpeakersEndpoint(eventId: eventId),
            as: EventSpeakersDTO.self
        )
        return (dto.speakers ?? []).map { Speaker(eventSpeaker: $0) }
    }

    func fetchEventDetails(id: UUID) async throws -> (event: Event, speakers: [Speaker]) {
        async let eventDTO: EventDTO = network.requestDecodable(
            GetEventEndpoint(id: id),
            as: EventDTO.self
        )
        async let speakers = fetchEventSpeakers(eventId: id)
        let (fetchedEvent, fetchedSpeakers) = try await (eventDTO, speakers)
        let event = EventMapping.domain(from: fetchedEvent, speakerIDs: fetchedSpeakers.map(\.id))
        return (event, fetchedSpeakers)
    }

    func toggleLike(eventId: UUID) async throws -> Bool {
        let dto: EventLikeDTO = try await network.requestDecodable(
            PostEventLikeEndpoint(eventId: eventId),
            as: EventLikeDTO.self
        )
        return dto.isLiked
    }
}
```

### 6.11 `Sources/App/AppServices.swift`

```swift
import Foundation

enum AppServices {
    static func makeEventsRepository() -> EventsRepositoryProtocol {
        let tokenStorage = KeychainTokenStorage()
        let authorization = AuthorizationProvider(tokenStorage: tokenStorage)
        let network = NetworkService(authorizationProvider: authorization)
        return EventsRepository(network: network)
    }
}
```

### 6.12 `Sources/Presentation/Schedule/Event/EventCard/EventCardViewModel.swift`

```swift
import Foundation
import SwiftUI

@MainActor
final class EventCardViewModel: ObservableObject {
    @Published private(set) var event: Event
    @Published private(set) var zone: Zone?
    @Published private(set) var speakers: [Speaker]
    @Published private(set) var isLiked: Bool
    @Published private(set) var isLikeOperationInFlight = false

    private let eventsRepository: EventsRepositoryProtocol?

    init(
        event: Event,
        zone: Zone?,
        speakers: [Speaker],
        isLiked: Bool = false,
        eventsRepository: EventsRepositoryProtocol? = nil
    ) {
        self.event = event
        self.zone = zone
        self.speakers = speakers
        self.isLiked = isLiked
        self.eventsRepository = eventsRepository
    }

    var canToggleLike: Bool { eventsRepository != nil }

    var timeRangeText: String {
        let start = event.start.formatted(date: .omitted, time: .shortened)
        let end = event.end.formatted(date: .omitted, time: .shortened)
        return "\(start) – \(end)"
    }

    var isLive: Bool {
        let now = Date()
        return now >= event.start && now <= event.end
    }

    var showsStreamControl: Bool {
        isLive && event.streamURL != nil
    }

    var primarySpeaker: Speaker? { speakers.first }

    func toggleLike() async {
        guard let eventsRepository else { return }
        isLikeOperationInFlight = true
        defer { isLikeOperationInFlight = false }
        do {
            isLiked = try await eventsRepository.toggleLike(eventId: event.id)
        } catch {
            // по желанию: @Published error / лог
        }
    }

    func refreshFromNetwork() async throws {
        guard let eventsRepository else { return }
        let details = try await eventsRepository.fetchEventDetails(id: event.id)
        event = details.event
        speakers = details.speakers
    }
}

#if DEBUG
extension EventCardViewModel {
    static func preview(
        event: Event = EventCardMocks.event,
        zone: Zone? = EventCardMocks.zone,
        speakers: [Speaker] = EventCardMocks.speakers,
        likesInitially: Bool = false,
        withLikeAction: Bool = true
    ) -> EventCardViewModel {
        EventCardViewModel(
            event: event,
            zone: zone,
            speakers: speakers,
            isLiked: likesInitially,
            eventsRepository: withLikeAction ? PreviewToggleLikeRepository(isLiked: likesInitially) : nil
        )
    }
}

private final class PreviewToggleLikeRepository: EventsRepositoryProtocol {
    private var liked: Bool

    init(isLiked: Bool) {
        liked = isLiked
    }

    func fetchEvent(id _: UUID) async throws -> Event {
        preconditionFailure("не используется в превью карточки")
    }

    func fetchEvents(festivalId _: UUID) async throws -> [Event] {
        preconditionFailure("не используется в превью карточки")
    }

    func fetchEventSpeakers(eventId _: UUID) async throws -> [Speaker] {
        preconditionFailure("не используется в превью карточки")
    }

    func fetchEventDetails(id _: UUID) async throws -> (event: Event, speakers: [Speaker]) {
        preconditionFailure("не используется в превью карточки")
    }

    func toggleLike(eventId _: UUID) async throws -> Bool {
        liked.toggle()
        return liked
    }
}
#endif
```

### 6.13 `EventCard.swift` — вариант с ViewModel и кнопкой лайка

Ниже полный файл **заменяет** текущую реализацию `EventCard`, если вы подключаете `EventCardViewModel`. Сохранены моки и вспомогательные `LivePulseDot` / `SpeakerAvatar`.

```swift
import Foundation
import SwiftUI

// MARK: - Mocks (данные для карточки события)

enum EventCardMocks {
    enum IDs {
        static let event = Self.uuid("11111111-1111-1111-1111-111111111111")
        static let zone = Self.uuid("22222222-2222-2222-2222-222222222222")
        static let speaker1 = Self.uuid("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
        static let speaker2 = Self.uuid("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")

        private static func uuid(_ string: String) -> UUID {
            guard let id = UUID(uuidString: string) else {
                preconditionFailure("Invalid mock UUID string: \(string)")
            }
            return id
        }
    }

    static let zone = Zone(
        id: IDs.zone,
        name: "Главная сцена",
        iconName: "theatermasks.fill",
        color: "indigo"
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: IDs.speaker1,
            name: "Иван Петров",
            role: "Lead iOS Developer",
            bio: """
            Иван работает в Яндексе более 5 лет. Руководит разработкой мобильного приложения Яндекс.Карт.
            Спикер конференций Mobius и RIW. Увлекается SwiftUI и анимациями.
            """,
            photoURL: URL(string: "https://example.com/photos/ivan-petrov.jpg")
        ),
        Speaker(
            id: IDs.speaker2,
            name: "Мария Соколова",
            role: "Staff Engineer, Mobile Platform",
            bio: """
            Архитектура и производительность больших iOS-клиентов. Ранее — лид мобильной разработки в e-commerce.
            """,
            photoURL: URL(string: "https://example.com/photos/maria-sokolova.jpg")
        ),
    ]

    static var event: Event {
        let now = Date()
        return Event(
            id: IDs.event,
            title: "Разработка на Swift: современные подходы и best practices",
            start: now.addingTimeInterval(-30 * 60),
            end: now.addingTimeInterval(2 * 60 * 60),
            speakerIDs: [IDs.speaker1, IDs.speaker2],
            zoneID: IDs.zone,
            categoryCode: "development",
            streamURL: URL(string: "https://example.com/stream/2026/swift-talk")
        )
    }
}

// MARK: - EventCard

private enum EventCardPalette {
    static let timeText = Color(red: 208 / 255, green: 208 / 255, blue: 211 / 255)
    static let locationText = Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
    static let speakerAvatar = Color(red: 53 / 255, green: 55 / 255, blue: 84 / 255)
}

struct EventCard: View {
    @ObservedObject private var viewModel: EventCardViewModel

    init(viewModel: EventCardViewModel) {
        self.viewModel = viewModel
    }

    init(event: Event, zone: Zone?, speakers: [Speaker], isLiked: Bool = false, eventsRepository: EventsRepositoryProtocol? = nil) {
        viewModel = EventCardViewModel(
            event: event,
            zone: zone,
            speakers: speakers,
            isLiked: isLiked,
            eventsRepository: eventsRepository
        )
    }

    var body: some View {
        cardStack
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { cardBackground }
            .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }

    private var cardStack: some View {
        VStack(alignment: .leading, spacing: 14) {
            scheduleRow
            titleBlock
            if let speaker = viewModel.primarySpeaker {
                speakerRow(speaker)
            }
            separatorLine
            metaRow
        }
    }

    private var scheduleRow: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(viewModel.timeRangeText)
                .font(.footnote)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(EventCardPalette.timeText)

            if viewModel.isLive {
                LivePulseDot()
            }

            Spacer(minLength: 8)
        }
    }

    private var titleBlock: some View {
        Text(viewModel.event.title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func speakerRow(_ speaker: Speaker) -> some View {
        HStack(alignment: .center, spacing: 12) {
            SpeakerAvatar(url: speaker.photoURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(speaker.name)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(speaker.role)
                    .font(.caption)
                    .foregroundStyle(YoungConAsset.gray500.swiftUIColor)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(YoungConAsset.gray500.swiftUIColor.opacity(0.35))
            .frame(height: 1)
    }

    private var metaRow: some View {
        HStack(alignment: .center, spacing: 12) {
            if let zone = viewModel.zone {
                HStack(spacing: 6) {
                    Image(systemName: zone.iconName)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(zoneAccentColor(zone.color))
                    Text(zone.name)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(EventCardPalette.locationText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            if viewModel.canToggleLike {
                Button {
                    Task { await viewModel.toggleLike() }
                } label: {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(viewModel.isLiked ? Color.red : EventCardPalette.locationText)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLikeOperationInFlight)
            }

            if viewModel.showsStreamControl {
                EventCardStreamButton()
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(red: 21 / 255, green: 22 / 255, blue: 33 / 255))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(YoungConAsset.gray500.swiftUIColor.opacity(0.22), lineWidth: 1)
            }
    }

    private func zoneAccentColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "pink", "red":
            YoungConAsset.accentPink.swiftUIColor
        case "orange", "yellow":
            YoungConAsset.accentYellow.swiftUIColor
        case "indigo", "blue", "purple", "green", "mint", "teal", "cyan":
            YoungConAsset.accentPurple.swiftUIColor
        default:
            YoungConAsset.accentPurple.swiftUIColor
        }
    }
}

private struct LivePulseDot: View {
    @State private var dimmed = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 6, height: 6)
            .opacity(dimmed ? 0.38 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                    dimmed = true
                }
            }
    }
}

private struct SpeakerAvatar: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(EventCardPalette.speakerAvatar.opacity(0.55), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            EventCardPalette.speakerAvatar.opacity(0.35)
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

#Preview("Карточка") {
    EventCard(viewModel: .preview())
        .padding()
        .background(YoungConAsset.appBackground.swiftUIColor)
        .preferredColorScheme(.dark)
}

#Preview("Без зоны и эфира") {
    let previewEvent = Event(
        id: EventCardMocks.IDs.event,
        title: "Короткий доклад",
        start: Date(),
        end: Date().addingTimeInterval(3600),
        speakerIDs: [EventCardMocks.IDs.speaker1],
        zoneID: nil,
        categoryCode: "talk",
        streamURL: nil
    )
    EventCard(
        viewModel: EventCardViewModel(
            event: previewEvent,
            zone: nil,
            speakers: [EventCardMocks.speakers[0]],
            eventsRepository: nil
        )
    )
    .padding()
    .background(YoungConAsset.appBackground.swiftUIColor)
    .preferredColorScheme(.dark)
}
```

### 6.14 Пример вызова с репозиторием

```swift
let repo = AppServices.makeEventsRepository()
let vm = EventCardViewModel(
    event: event,
    zone: zone,
    speakers: speakers,
    isLiked: false,
    eventsRepository: repo
)
EventCard(viewModel: vm)
```

После добавления файлов выполните **`tuist generate`**.

---

## 7. Ссылки на API

- [Swagger UI](http://213.165.218.183:8080/swagger/index.html)
- [OpenAPI JSON](http://213.165.218.183:8080/swagger/v1/swagger.json)

---

*Дополняйте разделами под команду: стиль ошибок, тесты, навигация.*
