import Foundation
import XCTest
@testable import YoungCon

final class ZoneIconURLClassifierTests: XCTestCase {
    /// Проверяет, что для URL с хостом `disk.yandex.ru` используется кастомный провайдер Yandex Disk.
    func testUsesYandexDiskProvider_whenHostIsDiskYandexRu_returnsTrue() throws {
        let url = try XCTUnwrap(URL(string: "https://disk.yandex.ru/i/test-icon"))

        XCTAssertTrue(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }

    /// Проверяет, что для короткого хоста `yadi.sk` тоже используется кастомный провайдер Yandex Disk.
    func testUsesYandexDiskProvider_whenHostIsYadiSk_returnsTrue() throws {
        let url = try XCTUnwrap(URL(string: "https://yadi.sk/i/test-icon"))

        XCTAssertTrue(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }

    /// Проверяет, что для не-Yandex хостов используется обычная загрузка через Kingfisher.
    func testUsesYandexDiskProvider_whenHostIsNotYandex_returnsFalse() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/icon.png"))

        XCTAssertFalse(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }
}
