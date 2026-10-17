import XCTest

/// End-to-end UI test for the returning-user flow.
///
/// Verifies that a user who has already completed onboarding (and thus has a
/// saved profile) skips the splash guest entry and onboarding, landing directly
/// on the main menu when the app is relaunched.
///
/// This test runs out-of-process and cannot seed SwiftData directly, so it
/// first walks the full onboarding flow to persist a profile, then terminates
/// and relaunches the app to verify the returning-user routing.
final class ReturningUserUITests: XCTestCase {

    /// Mirrors `OnboardingAccessibility` / `SplashAccessibility` / `MainMenuAccessibility`
    /// (which this bundle cannot import).
    private enum Identifier {
        static let guest = "splash.guest"
        static let next = "onboarding.next"
        static let value = "onboarding.value"
        static let mainMenu = "mainmenu.title"

        static func goalCard(_ index: Int) -> String { "onboarding.goal.\(index)" }
        static func sexOption(_ index: Int) -> String { "onboarding.sex.\(index)" }
        static func activityCard(_ index: Int) -> String { "onboarding.activity.\(index)" }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Walks onboarding to persist a profile, terminates, relaunches, and verifies
    /// the app lands directly on the main menu (skipping splash guest + onboarding).
    @MainActor
    func testReturningUserSkipsOnboardingAndLandsOnMainMenu() throws {
        // First launch: complete onboarding to persist a profile.
        let app = XCUIApplication()
        app.launch()

        tap(button(Identifier.guest, in: app))
        tapNext(in: app)
        tap(button(Identifier.goalCard(0), in: app))
        tapNext(in: app)
        tap(button(Identifier.sexOption(0), in: app))
        tapNext(in: app)
        tapNext(in: app)
        tapNext(in: app)
        tap(button(Identifier.activityCard(0), in: app))
        tapNext(in: app)

        // Verify we reached the main menu.
        XCTAssertTrue(
            app.staticTexts[Identifier.mainMenu].waitForExistence(timeout: 20),
            "Expected the app to navigate to the main menu after onboarding"
        )

        // Terminate and relaunch.
        app.terminate()
        app.launch()

        // Returning user: splash auto-finishes, lands directly on main menu.
        // The guest button should NOT appear (onboarding is skipped).
        XCTAssertTrue(
            app.staticTexts[Identifier.mainMenu].waitForExistence(timeout: 20),
            "Expected the returning user to land directly on the main menu"
        )

        // Verify onboarding was skipped — the guest button should not exist.
        XCTAssertFalse(
            app.buttons[Identifier.guest].exists,
            "Returning user should not see the splash guest button"
        )
    }

    // MARK: - Helpers

    @MainActor
    private func button(
        _ identifier: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 20,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        let query = app.buttons.matching(identifier: identifier)
        wait(for: NSPredicate(format: "count == 1"), on: query, timeout: timeout, file: file, line: line)
        return query.firstMatch
    }

    @MainActor
    private func nextButton(in app: XCUIApplication) -> XCUIElement {
        button(Identifier.next, in: app)
    }

    @MainActor
    private func tapNext(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        tap(nextButton(in: app), file: file, line: line)
    }

    @MainActor
    private func tap(
        _ element: XCUIElement,
        timeout: TimeInterval = 20,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        wait(for: NSPredicate(format: "hittable == true"), on: element, timeout: timeout, file: file, line: line)
        element.tap()
    }

    @MainActor
    private func wait(
        for predicate: NSPredicate,
        on object: Any,
        timeout: TimeInterval,
        message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: object)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, message, file: file, line: line)
    }
}
