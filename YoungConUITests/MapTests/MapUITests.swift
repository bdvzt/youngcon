import XCTest

final class MapUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Проверяет, что экран карты открывается на первом зафиксированном этаже и не уходит ниже него.
    @MainActor
    func testMapScreen_displaysStubbedFirstFloor() {
        let app = launchMapApp()

        let screen = element(in: app, id: "map.screen")
        let floorNumber = element(in: app, id: "map.floor.number")
        let previousFloorButton = element(in: app, id: "map.floor.previous")
        let nextFloorButton = element(in: app, id: "map.floor.next")
        let mainStageChip = element(in: app, id: "map.zoneChip.zone-main-stage")
        let careerChip = element(in: app, id: "map.zoneChip.zone-career")

        XCTAssertTrue(screen.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["map.header.title"].exists)
        XCTAssertTrue(floorNumber.waitForExistence(timeout: 2))
        XCTAssertEqual(floorNumber.label, "1")
        XCTAssertTrue(previousFloorButton.exists)
        XCTAssertTrue(nextFloorButton.isHittable)

        previousFloorButton.tap()

        XCTAssertEqual(floorNumber.label, "1")
        XCTAssertTrue(mainStageChip.waitForExistence(timeout: 2))
        XCTAssertTrue(careerChip.exists)
    }

    /// Проверяет, что переход на следующий этаж обновляет номер этажа и список видимых зон.
    @MainActor
    func testMapScreen_switchesFloorAndUpdatesZoneList() {
        let app = launchMapApp()
        let nextFloorButton = element(in: app, id: "map.floor.next")
        let floorNumber = element(in: app, id: "map.floor.number")
        let workshopsChip = element(in: app, id: "map.zoneChip.zone-workshops")
        let mainStageChip = element(in: app, id: "map.zoneChip.zone-main-stage")
        let previousFloorButton = element(in: app, id: "map.floor.previous")

        XCTAssertTrue(nextFloorButton.waitForExistence(timeout: 5))

        nextFloorButton.tap()

        XCTAssertEqual(floorNumber.label, "2")
        XCTAssertTrue(workshopsChip.waitForExistence(timeout: 2))
        XCTAssertFalse(mainStageChip.exists)
        XCTAssertTrue(previousFloorButton.isHittable)
    }

    /// Проверяет, что нажатие на чип зоны открывает попап, а кнопка закрытия скрывает его.
    @MainActor
    func testMapScreen_zoneChipShowsAndHidesPopup() {
        let app = launchMapApp()
        let zoneChip = element(in: app, id: "map.zoneChip.zone-main-stage")
        let popup = element(in: app, id: "map.popup.zone-main-stage")
        let popupClose = element(in: app, id: "map.popup.close")
        XCTAssertTrue(zoneChip.waitForExistence(timeout: 5))

        zoneChip.tap()

        XCTAssertTrue(popup.waitForExistence(timeout: 2))

        popupClose.tap()

        XCTAssertTrue(popup.waitForNonExistence(timeout: 2))
    }

    /// Проверяет, что у чипов зон на первом этаже доступны accessibility-элементы для иконок.
    @MainActor
    func testMapScreen_zoneChipsDisplayIcons() {
        let app = launchMapApp()
        let mainStageIcon = element(in: app, id: "map.zoneChip.icon.zone-main-stage")
        let careerIcon = element(in: app, id: "map.zoneChip.icon.zone-career")

        XCTAssertTrue(mainStageIcon.waitForExistence(timeout: 5))
        XCTAssertTrue(careerIcon.exists)
    }

    @MainActor
    private func launchMapApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["--uitesting-map"]
        app.launchEnvironment.merge(MapUITestFixture.launchEnvironment) { _, newValue in
            newValue
        }
        app.launch()
        return app
    }

    @MainActor
    private func element(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }
}
