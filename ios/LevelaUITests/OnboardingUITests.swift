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
    /// packages (which this bundle cannot import) plus the app-level
    /// `MainMenuAccessibility`.
    private enum Identifier {
        static let guest = "splash.guest"
        static let next = "onboarding.next"
        static let back = "onboarding.back"
        static let skip = "onboarding.skip"
        static let value = "onboarding.value"
        static let mainMenu = "mainmenu.title"

        static func goalCard(_ index: Int) -> String { "onboarding.goal.\(index)" }
        static func genderCard(_ index: Int) -> String { "onboarding.gender.\(index)" }
        static func activityCard(_ index: Int) -> String { "onboarding.activity.\(index)" }
        static func age(_ value: Int) -> String { "onboarding.age.\(value)" }
        static func unit(_ unit: String) -> String { "onboarding.unit.\(unit)" }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - The full flow

    /// Walks all seven steps the way a guest would: the splash guest entry, the
    /// gating on each single-select step, the weight/height unit toggles (which
    /// must convert without losing the measurement) and the final Next, which
    /// navigates on to the mock main menu.
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

        // Goal -> gender: Continue waits for a gender choice.
        tapNext(in: app)
        XCTAssertFalse(nextButton(in: app).isEnabled)
        tap(button(Identifier.genderCard(1), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)

        // Gender -> age: the age always has a default, so Next is enabled.
        tapNext(in: app)
        assertValue(in: app, equals: "30") // OnboardingTokens.ageDefault
        XCTAssertTrue(nextButton(in: app).isEnabled)

        // The age wheel selects a tapped neighbour and centres it.
        let nextAge = Identifier.age(31) // ageDefault + 1
        let ageRow = app.staticTexts[nextAge]
        XCTAssertTrue(ageRow.waitForExistence(timeout: 20))
        // The wheel must open centred, with the neighbouring age on screen.
        XCTAssertTrue(ageRow.isHittable)
        // Tap by coordinate: selecting a row swaps its identifier to
        // `onboarding.value`, so the element handle is stale straight after.
        ageRow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        assertValue(in: app, equals: "31")

        // Age -> weight: the unit toggle converts 70 kg to 154 lb.
        tapNext(in: app)
        assertValue(in: app, equals: "70") // weightKgDefault
        tap(button(Identifier.unit("lb"), in: app))
        assertValue(in: app, equals: "154")

        // Weight -> height: 170 cm renders as 5'7" in feet/inches.
        tapNext(in: app)
        assertValue(in: app, equals: "170") // heightCmDefault
        tap(button(Identifier.unit("ft/in"), in: app))
        assertValue(in: app, equals: "5'7\"")

        // Height -> activity: gates Next, then the final Next reports completion
        // and the app navigates on to the mock main menu.
        tapNext(in: app)
        XCTAssertFalse(nextButton(in: app).isEnabled)
        tap(button(Identifier.activityCard(0), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)
        tapNext(in: app)

        // Completion navigates on: the mock main menu replaces the onboarding
        // flow (the app keeps running).
        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertTrue(
            app.staticTexts[Identifier.mainMenu].waitForExistence(timeout: 20),
            "Expected the app to navigate to the mock main menu after onboarding"
        )
    }

    // MARK: - Drag / swipe

    /// Dragging the age wheel selects the age that snaps to the centre, not just
    /// a scrolled-away row: the committed value changes and Next stays enabled.
    @MainActor
    func testAgeWheelSwipeSelectsAnAge() throws {
        let app = launch()
        goToAgeStep(in: app)

        let initial = valueLabel(in: app)
        var swipes = 0
        while valueLabel(in: app) == initial && swipes < 6 {
            app.staticTexts[Identifier.value].swipeUp()
            swipes += 1
        }

        XCTAssertNotEqual(
            valueLabel(in: app),
            initial,
            "Swiping the wheel should select a new centred age"
        )
        XCTAssertTrue(nextButton(in: app).isEnabled)
    }

    /// Flinging the wheel past the youngest age clamps at the contract minimum
    /// (13) instead of selecting an out-of-range value.
    @MainActor
    func testAgeWheelSwipeStaysWithinBounds() throws {
        let app = launch()
        goToAgeStep(in: app)

        // Fling down repeatedly until the wheel reaches the minimum.
        var swipes = 0
        while valueLabel(in: app) != "13" && swipes < 15 {
            app.staticTexts[Identifier.value].swipeDown()
            swipes += 1
        }
        XCTAssertEqual(valueLabel(in: app), "13")

        // Further swipes cannot push the selection below the minimum.
        for _ in 0..<3 {
            app.staticTexts[Identifier.value].swipeDown()
        }
        XCTAssertEqual(valueLabel(in: app), "13")
        XCTAssertTrue(nextButton(in: app).isEnabled)
    }

    /// Swiping the gender carousel only snaps it; it must not count as picking a
    /// gender. Tapping the newly centred card then selects it.
    @MainActor
    func testGenderCarouselSwipeSnapsWithoutSelecting() throws {
        let app = launch()
        goToGenderStep(in: app)

        XCTAssertFalse(nextButton(in: app).isEnabled)

        // CAROUSEL SWIPE: card 1 (the centre initially) -> card 2.
        app.buttons[Identifier.genderCard(1)].swipeLeft()

        XCTAssertFalse(
            nextButton(in: app).isEnabled,
            "Swiping the carousel must not select a gender"
        )

        // Tapping the card that snapped to the centre selects it.
        tap(button(Identifier.genderCard(2), in: app))
        XCTAssertTrue(nextButton(in: app).isEnabled)
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

    /// Enters through the splash guest button and moves to the gender step.
    @MainActor
    private func goToGenderStep(in app: XCUIApplication) {
        tap(button(Identifier.guest, in: app))

        // Welcome -> goal -> gender.
        tapNext(in: app)
        tap(button(Identifier.goalCard(0), in: app))
        tapNext(in: app)
    }

    /// Moves from the gender step to the age step with a gender selected.
    @MainActor
    private func goToAgeStep(in app: XCUIApplication) {
        goToGenderStep(in: app)
        tap(button(Identifier.genderCard(1), in: app))
        tapNext(in: app)
        _ = valueLabel(in: app)
    }

    /// Reads the committed value shown by the age wheel / weight / height card.
    @MainActor
    private func valueLabel(in app: XCUIApplication, timeout: TimeInterval = 20) -> String {
        let query = app.staticTexts.matching(identifier: Identifier.value)
        wait(for: NSPredicate(format: "count == 1"), on: query, timeout: timeout)
        return query.firstMatch.label
    }

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

    /// Reads the age wheel's centred row (or the weight / height value card) and
    /// waits for it to show `expected` — the value changes in place when the
    /// wheel moves or the unit is toggled.
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
