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
@MainActor
final class OnboardingViewTests: XCTestCase {

    // MARK: - Welcome

    func testWelcomeStepShowsCopyAndStartAdvances() throws {
        let view = OnboardingView(step: .welcome)

        try view.inspect().find(text: OnboardingTokens.welcomeTitle)
        try view.inspect().find(text: OnboardingTokens.welcomeSubtitle)

        try nextButton(in: view).tap()

        try view.inspect().find(text: OnboardingTokens.goalTitle)
    }

    // MARK: - Goal

    func testGoalStepGatesNextUntilAGoalIsChosen() throws {
        let view = OnboardingView(step: .goal)

        try view.inspect().find(text: OnboardingTokens.goalTitle)
        XCTAssertTrue(try nextButton(in: view).isDisabled())

        try view.inspect().find(button: OnboardingTokens.goals[0].title).tap()

        XCTAssertFalse(try nextButton(in: view).isDisabled())
    }

    func testGoalStepBackReturnsToWelcome() throws {
        let view = OnboardingView(step: .goal)

        try backButton(in: view).tap()

        try view.inspect().find(text: OnboardingTokens.welcomeTitle)
    }

    // MARK: - Profile

    func testProfileStepGatesNextUntilSexIsChosen() throws {
        let view = OnboardingView(step: .profile)

        try view.inspect().find(text: OnboardingTokens.profileTitle)
        try view.inspect().find(text: "\(OnboardingTokens.ageDefault)")
        XCTAssertTrue(try nextButton(in: view).isDisabled())

        try view.inspect().find(button: OnboardingTokens.sexOptions[0]).tap()

        XCTAssertFalse(try nextButton(in: view).isDisabled())
    }

    // MARK: - Weight & height

    func testWeightUnitTogglePreservesTheMeasurement() throws {
        let view = OnboardingView(step: .weight)

        try view.inspect().find(text: OnboardingTokens.weightTitle)
        try view.inspect().find(text: "\(OnboardingTokens.weightKgDefault)")

        // The unselected option is the only single match (the selected one is
        // also echoed under the ruler), so tapping it is unambiguous.
        try view.inspect().find(button: "lb").tap()

        try view.inspect().find(text: "\(OnboardingTokens.weightLbDefault)")
    }

    func testHeightUnitToggleShowsFeetAndInches() throws {
        let view = OnboardingView(step: .height)

        try view.inspect().find(text: OnboardingTokens.heightTitle)
        try view.inspect().find(text: "\(OnboardingTokens.heightCmDefault)")

        try view.inspect().find(button: "ft/in").tap()

        try view.inspect().find(text: "5'7\"")
    }

    // MARK: - Activity & completion

    func testActivityStepGatesNextAndCompletes() throws {
        var finished = false
        var saved: OnboardingProfile?
        let view = OnboardingView(step: .activity) { profile in
            finished = true
            saved = profile
        }

        try view.inspect().find(text: OnboardingTokens.activityTitle)
        XCTAssertTrue(try nextButton(in: view).isDisabled())

        try view.inspect().find(button: OnboardingTokens.activityLevels[0].title).tap()
        XCTAssertFalse(try nextButton(in: view).isDisabled())

        try nextButton(in: view).tap()

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

        // Welcome -> Goal
        try view.inspect().find(text: OnboardingTokens.welcomeTitle)
        try nextButton(in: view).tap()

        // Goal -> Profile
        try view.inspect().find(text: OnboardingTokens.goalTitle)
        try view.inspect().find(button: OnboardingTokens.goals[0].title).tap()
        try nextButton(in: view).tap()

        // Profile -> Weight
        try view.inspect().find(text: OnboardingTokens.profileTitle)
        try view.inspect().find(button: OnboardingTokens.sexOptions[0]).tap()
        try nextButton(in: view).tap()

        // Weight -> Height
        try view.inspect().find(text: OnboardingTokens.weightTitle)
        try nextButton(in: view).tap()

        // Height -> Activity
        try view.inspect().find(text: OnboardingTokens.heightTitle)
        try nextButton(in: view).tap()

        // Activity -> finish
        try view.inspect().find(text: OnboardingTokens.activityTitle)
        XCTAssertTrue(try nextButton(in: view).isDisabled())
        try view.inspect().find(button: OnboardingTokens.activityLevels[0].title).tap()
        try nextButton(in: view).tap()

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
    private func nextButton(in view: OnboardingView) throws -> InspectableView<ViewType.Button> {
        try view.inspect().find(ViewType.Button.self) { button in
            try button.accessibilityIdentifier() == OnboardingAccessibility.next
        }
    }

    /// The Back button, which has no text of its own.
    private func backButton(in view: OnboardingView) throws -> InspectableView<ViewType.Button> {
        try view.inspect().find(ViewType.Button.self) { button in
            try button.accessibilityIdentifier() == OnboardingAccessibility.back
        }
    }
}
