import SwiftUI
import ViewInspector
import XCTest
@testable import Onboarding

/// UI tests for ``OnboardingView``.
///
/// Each test drops the flow onto a chosen step (through the internal
/// `init(step:onFinished:)` the previews use) and drives it through the real
/// SwiftUI view, so the step gating, unit toggles and completion wiring are
/// exercised. Content is asserted against the shared ``OnboardingTokens`` (never
/// hardcoded copy); the text-less back button is located by its accessibility
/// identifier. Mirrors the Android `OnboardingViewTest`.
///
/// The step is seeded rather than walked from the default entry point: with no
/// hosting controller, SwiftUI re-creates a `@State` value declared with a
/// property initializer on every access, so only the seeded view model survives
/// between inspections. Seeding (rather than injecting a view model) is the
/// closest iOS equivalent of the Android test's `setContent`.
///
/// ``OnboardingView`` holds its `@Observable` view model with `@State`, so View
/// Inspector's default `inspect()` reads `@State` without a real storage
/// location and emits a runtime warning. Hosting the view with
/// `ViewHosting.host(view:)` installs `@State` before each `inspect()` call,
/// which silences the warning and reads the live view model instance.
@MainActor
final class OnboardingViewTests: XCTestCase {

    // MARK: - Welcome

    func testWelcomeStepShowsCopyAndStartAdvances() throws {
        let view = OnboardingView(step: .welcome)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.welcomeTitle)
        _ = try inspected.find(text: OnboardingTokens.welcomeSubtitle)

        try nextButton(inspected).tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: OnboardingTokens.goalTitle)
    }

    // MARK: - Goal

    func testGoalStepGatesNextUntilAGoalIsChosen() throws {
        let view = OnboardingView(step: .goal)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.goalTitle)
        XCTAssertTrue(try nextButton(inspected).isDisabled())

        try inspected.find(button: OnboardingTokens.goals[0].title).tap()

        XCTAssertFalse(try nextButton(try view.inspect()).isDisabled())
    }

    func testGoalStepBackReturnsToWelcome() throws {
        let view = OnboardingView(step: .goal)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        try backButton(inspected).tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: OnboardingTokens.welcomeTitle)
    }

    // MARK: - Profile

    func testProfileStepGatesNextUntilSexIsChosen() throws {
        let view = OnboardingView(step: .profile)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.profileTitle)
        _ = try inspected.find(text: "\(OnboardingTokens.ageDefault)")
        XCTAssertTrue(try nextButton(inspected).isDisabled())

        try inspected.find(button: OnboardingTokens.sexOptions[0]).tap()

        XCTAssertFalse(try nextButton(try view.inspect()).isDisabled())
    }

    // MARK: - Weight & height

    func testWeightUnitTogglePreservesTheMeasurement() throws {
        let view = OnboardingView(step: .weight)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.weightTitle)
        _ = try inspected.find(text: "\(OnboardingTokens.weightKgDefault)")

        // The unselected option is the only single match (the selected one is
        // also echoed under the ruler), so tapping it is unambiguous.
        try inspected.find(button: "lb").tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: "\(OnboardingTokens.weightLbDefault)")
    }

    func testHeightUnitToggleShowsFeetAndInches() throws {
        let view = OnboardingView(step: .height)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.heightTitle)
        _ = try inspected.find(text: "\(OnboardingTokens.heightCmDefault)")

        try inspected.find(button: "ft/in").tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: "5'7\"")
    }

    // MARK: - Activity & completion

    func testActivityStepGatesNextAndCompletes() throws {
        var finished = false
        var saved: OnboardingProfile?
        let view = OnboardingView(step: .activity) { profile in
            finished = true
            saved = profile
        }

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.activityTitle)
        XCTAssertTrue(try nextButton(inspected).isDisabled())

        try inspected.find(button: OnboardingTokens.activityLevels[0].title).tap()
        XCTAssertFalse(try nextButton(try view.inspect()).isDisabled())

        try nextButton(try view.inspect()).tap()

        XCTAssertTrue(finished)
        XCTAssertEqual(saved?.activityLevel, OnboardingTokens.activityLevels[0].title)
    }

    func testWalksTheWholeFlowAndFinishesOnce() throws {
        var finished = 0
        var saved: [OnboardingProfile] = []
        let view = OnboardingView(step: .welcome) { profile in
            finished += 1
            saved.append(profile)
        }

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        // Welcome -> Goal
        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.welcomeTitle)
        try nextButton(inspected).tap()

        // Goal -> Profile
        let inspected2 = try view.inspect()
        _ = try inspected2.find(text: OnboardingTokens.goalTitle)
        try inspected2.find(button: OnboardingTokens.goals[0].title).tap()
        try nextButton(try view.inspect()).tap()

        // Profile -> Weight
        let inspected3 = try view.inspect()
        _ = try inspected3.find(text: OnboardingTokens.profileTitle)
        try inspected3.find(button: OnboardingTokens.sexOptions[0]).tap()
        try nextButton(try view.inspect()).tap()

        // Weight -> Height
        let inspected4 = try view.inspect()
        _ = try inspected4.find(text: OnboardingTokens.weightTitle)
        try nextButton(try view.inspect()).tap()

        // Height -> Activity
        let inspected5 = try view.inspect()
        _ = try inspected5.find(text: OnboardingTokens.heightTitle)
        try nextButton(try view.inspect()).tap()

        // Activity -> finish
        let inspected6 = try view.inspect()
        _ = try inspected6.find(text: OnboardingTokens.activityTitle)
        XCTAssertTrue(try nextButton(inspected6).isDisabled())
        try inspected6.find(button: OnboardingTokens.activityLevels[0].title).tap()
        try nextButton(try view.inspect()).tap()

        XCTAssertEqual(finished, 1)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.goal, OnboardingTokens.goals[0].title)
        XCTAssertEqual(saved.first?.sex, OnboardingTokens.sexOptions[0])
        XCTAssertEqual(saved.first?.ageYears, OnboardingTokens.ageDefault)
        XCTAssertEqual(saved.first?.weightKg, Double(OnboardingTokens.weightKgDefault))
        XCTAssertEqual(saved.first?.heightCm, Double(OnboardingTokens.heightCmDefault))
        XCTAssertEqual(saved.first?.activityLevel, OnboardingTokens.activityLevels[0].title)
    }

    // MARK: - Helpers

    /// The Next button: located by identifier because its label also carries
    /// chevron images (the welcome step's "Let's start" variant included).
    private func nextButton(_ view: InspectableView<ViewType.ClassifiedView>) throws -> InspectableView<ViewType.Button> {
        try view.find(ViewType.Button.self) { button in
            try button.accessibilityIdentifier() == OnboardingAccessibility.next
        }
    }

    /// The Back button, which has no text of its own.
    private func backButton(_ view: InspectableView<ViewType.ClassifiedView>) throws -> InspectableView<ViewType.Button> {
        try view.find(ViewType.Button.self) { button in
            try button.accessibilityIdentifier() == OnboardingAccessibility.back
        }
    }
}
