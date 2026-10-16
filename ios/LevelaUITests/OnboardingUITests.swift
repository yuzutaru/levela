import XCTest

/// End-to-end UI tests for the splash → post-guest onboarding pipeline.
///
/// These run out of process through the real app (`XCUIApplication`) and drive it
/// by accessibility identifier, so they cover the parts the in-process
/// ViewInspector tests in the `Onboarding` package cannot: the actual SwiftUI
/// render/hit-test path, the step transitions, hittability and the package
/// boundary (splash reports completion and the app swaps in onboarding).
///
/// They reference only stable identifiers (`onboarding.*`, `splash.guest`) and
/// the contract's numeric defaults — never user-facing copy. A UI test bundle is
/// a separate process and cannot import the feature modules, so the identifiers
/// are repeated below; keep them in sync with `OnboardingAccessibility` /
/// `SplashAccessibility`.
final class OnboardingUITests: XCTestCase {

    /// Mirrors `OnboardingAccessibility` / `SplashAccessibility` in the feature
    /// packages (which this bundle cannot import).
    private enum Identifier {
        static let guest = "splash.guest"
        static let next = "onboarding.next"
        static let back = "onboarding.back"
        static let value = "onboarding.value"

        static func goalCard(_ index: Int) -> String { "onboarding.goal.\(index)" }
        static func sexOption(_ index: Int) -> String { "onboarding.sex.\(index)" }
        static func activityCard(_ index: Int) -> String { "onboarding.activity.\(index)" }
        static func unit(_ unit: String) -> String { "onboarding.unit.\(unit)" }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - The full flow

    /// Walks all six steps the way a guest would: the splash guest entry, the
    /// gating on each single-select step, the weight/height unit toggles (which
    /// must convert without losing the measurement) and the final Next.
    @MainActor
    func testWalksTheWholeFlowAndCompletes() throws {
        let app = launch()

        // Splash -> guest entry -> onboarding welcome ("Let's start" carries the
        // same identifier as the later Next buttons).
        tap(button(Identifier.guest, in: app))

        // Welcome -> goal: Next stays disabled until a goal is chosen.
        tapNext(in: app)
        XCTAssertFalse(nextButton(in: app).isEnabled)
        tap(button(Identifier.goalCard(0), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)

        // Goal -> profile: the age always has a default, but Next waits for a sex.
        tapNext(in: app)
        assertValue(in: app, equals: "30") // OnboardingTokens.ageDefault
        XCTAssertFalse(nextButton(in: app).isEnabled)
        tap(button(Identifier.sexOption(0), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)

        // Profile -> weight: the unit toggle converts 70 kg to 154 lb.
        tapNext(in: app)
        assertValue(in: app, equals: "70") // weightKgDefault
        tap(button(Identifier.unit("lb"), in: app))
        assertValue(in: app, equals: "154")

        // Weight -> height: 170 cm renders as 5'7" in feet/inches.
        tapNext(in: app)
        assertValue(in: app, equals: "170") // heightCmDefault
        tap(button(Identifier.unit("ft/in"), in: app))
        assertValue(in: app, equals: "5'7\"")

        // Height -> activity: gates Next, then the final Next reports completion.
        tapNext(in: app)
        XCTAssertFalse(nextButton(in: app).isEnabled)
        tap(button(Identifier.activityCard(0), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)
        tapNext(in: app)

        // Completion is a callback, not a navigation: the flow stays on the
        // activity step and the app keeps running.
        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertEqual(app.buttons.matching(identifier: Identifier.activityCard(0)).count, 1)
    }

    // MARK: - Back navigation

    /// The back button (which has no text) returns to the previous step.
    @MainActor
    func testBackFromTheGoalStepReturnsToWelcome() throws {
        let app = launch()

        tap(button(Identifier.guest, in: app))
        tapNext(in: app)

        // On the goal step the back button is present and works.
        _ = button(Identifier.goalCard(0), in: app)
        tap(button(Identifier.back, in: app))

        // Back on welcome: no option card, and no back button (welcome is first).
        waitForZero(app.buttons.matching(identifier: Identifier.goalCard(0)))
        waitForZero(app.buttons.matching(identifier: Identifier.back))
    }

    // MARK: - Helpers

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Waits for exactly one match and returns it. Transitions briefly leave both
    /// the outgoing and incoming step on screen, so a bare `firstMatch` can pick
    /// the wrong (leaving) control.
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

    /// Taps once the element is actually hittable, so fading-in controls (the
    /// splash actions, step transitions) are not tapped mid-animation.
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

    /// Reads the big value card (age / weight / height) and waits for it to show
    /// `expected` — the value changes in place when the unit is toggled.
    @MainActor
    private func assertValue(
        in app: XCUIApplication,
        equals expected: String,
        timeout: TimeInterval = 20,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let query = app.staticTexts.matching(identifier: Identifier.value)
        wait(for: NSPredicate(format: "count == 1"), on: query, timeout: timeout, file: file, line: line)
        wait(
            for: NSPredicate(format: "label == %@", expected),
            on: query.firstMatch,
            timeout: timeout,
            message: "Expected the value card to read \"\(expected)\", found \"\(query.firstMatch.label)\"",
            file: file,
            line: line
        )
    }

    @MainActor
    private func waitForZero(
        _ query: XCUIElementQuery,
        timeout: TimeInterval = 20,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        wait(for: NSPredicate(format: "count == 0"), on: query, timeout: timeout, file: file, line: line)
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
