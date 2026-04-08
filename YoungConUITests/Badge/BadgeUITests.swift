import XCTest

final class BadgeViewModelUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Передаем логин/пароль, если нужно, или используем хардкод как у вас
        loginIfNeeded(email: "yaganova@gmail.com", password: "12345678")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper

    private func loginIfNeeded(email: String, password: String) {
        // 1. Ждем, пока приложение выйдет из состояния isCheckingSession.
        //  ждем появления ЛИБО кнопки "Войти" (экран логина), ЛИБО кнопки "Бейдж" (главный экран).
        // Таймаут 5 секунд дадут время на загрузку данных.

        let loginButton = app.buttons["Войти"]
        let badgeTab = app.buttons["Бейдж"]

        let appeared = loginButton.waitForExistence(timeout: 5) || badgeTab.exists

        if !appeared {
            XCTFail("Приложение зависло на сплэше или неизвестное состояние")
            return
        }

        // Если мы уже на главном экране, выходим
        if badgeTab.exists { return }

        // --- Логика входа ---

        // 2. Вводим email
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists, "Поле Email должно существовать")
        emailField.tap()
        emailField.clearTextAndType(text: email) // Используем улучшенный метод

        // 3. Вводим пароль
        // CustomTextField с isSecure=true может определяться по-разному.
        // Ищем и среди secure, и среди обычных textFields по плейсхолдеру "Пароль".
        var passwordField = app.secureTextFields["Пароль"]
        if !passwordField.exists {
            passwordField = app.textFields["Пароль"]
        }

        XCTAssertTrue(passwordField.exists, "Поле Пароль должно существовать")
        passwordField.tap()
        passwordField.clearTextAndType(text: password)

        // 4. Нажимаем вход
        loginButton.tap()

        // 5. Ждем перехода на главный экран
        XCTAssertTrue(badgeTab.waitForExistence(timeout: 5), "Не удалось войти: главный экран не появился")
    }

    func testBadgeTabExistsAndDisplaysContent() {
        let badgeTabButton = app.buttons["Бейдж"]
        XCTAssertTrue(badgeTabButton.waitForExistence(timeout: 2), "Кнопка таба 'Бейдж' должна существовать")
        badgeTabButton.tap()

        let participantLabel = app.staticTexts["Участник / 2026"]
        XCTAssertTrue(participantLabel.waitForExistence(timeout: 2), "Метка 'Участник / 2026' должна отображаться")

        let achievementsHeader = app.staticTexts["Ачивки"]
        XCTAssertTrue(achievementsHeader.exists, "Заголовок 'Ачивки' должен отображаться")

        let qrImage = app.images.firstMatch
        XCTAssertTrue(qrImage.exists, "QR-код должен отображаться")
    }

    func testOpenQRModal() {
        app.buttons["Бейдж"].tap()

        let qrImage = app.images.firstMatch
        XCTAssertTrue(qrImage.waitForExistence(timeout: 1))
        qrImage.tap()

        let modalTitle = app.staticTexts["Отсканируй"]
        XCTAssertTrue(modalTitle.waitForExistence(timeout: 1), "Модальное окно QR должно открыться")

        let closeButton = app.buttons["xmark"]
        if closeButton.exists {
            closeButton.tap()
        } else {
            app.tap()
        }

        // Даем время на анимацию закрытия
        sleep(1)
        XCTAssertFalse(modalTitle.exists, "Модальное окно должно закрыться")
    }

    func testOpenStickerDetail() {
        app.buttons["Бейдж"].tap()

        let scrollViews = app.scrollViews
        if scrollViews.firstMatch.exists {
            let stickerButtons = scrollViews.firstMatch.buttons
            if stickerButtons.count > 0 {
                stickerButtons.firstMatch.tap()

                let statusText = app.staticTexts["Разблокировано"]
                XCTAssertTrue(statusText.waitForExistence(timeout: 1), "Детальная карточка стикера должна открыться")

                app.buttons["xmark"].tap()
            } else {
                print("Стикеры не найдены в скролле")
            }
        } else {
            XCTFail("Скролл вью не найдена")
        }
    }

    func testLogoutButtonShowsConfirmation() {
        app.buttons["Бейдж"].tap()

        let logoutButton = app.buttons["Выйти"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 2), "Кнопка выхода должна быть видна")

        logoutButton.tap()

        let alertTitle = app.staticTexts["Выйти из аккаунта?"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 1), "Алерт подтверждения должен появиться")

        let cancelButton = app.buttons["Отмена"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()

        sleep(1) // Ждем закрытия алерта
        XCTAssertFalse(alertTitle.exists, "Алерт должен исчезнуть после отмены")
    }
}

// MARK: - Расширения для работы с текстом

extension XCUIElement {
    func clearTextAndType(text: String) {
        tap()

        let currentValue = value as? String ?? ""

        if !currentValue.isEmpty {
            press(forDuration: 1.0)

            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count + 10)
            typeText(deleteString)
        }

        typeText(text)
    }

    func clearText() {
        guard let stringValue = value as? String else {
            return
        }
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        typeText(deleteString)
    }
}
