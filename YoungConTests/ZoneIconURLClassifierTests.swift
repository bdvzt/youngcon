import Foundation
import XCTest
@testable import YoungCon

final class ZoneIconURLClassifierTests: XCTestCase {
    func testUsesYandexDiskProvider_whenHostIsDiskYandexRu_returnsTrue() throws {
        let url = try XCTUnwrap(URL(string: "https://disk.yandex.ru/i/test-icon"))

        XCTAssertTrue(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }

    func testUsesYandexDiskProvider_whenHostIsYadiSk_returnsTrue() throws {
        let url = try XCTUnwrap(URL(string: "https://yadi.sk/i/test-icon"))

        XCTAssertTrue(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }

    func testUsesYandexDiskProvider_whenHostIsNotYandex_returnsFalse() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/icon.png"))

        XCTAssertFalse(ZoneIconURLClassifier.usesYandexDiskProvider(for: url))
    }
}
