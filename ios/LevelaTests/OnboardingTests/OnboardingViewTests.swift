import SwiftUI
import ViewInspector
import XCTest
@testable import Onboarding

/// UI tests for ``OnboardingView``.
///
/// Each test drops the flow onto a chosen step (through the internal
/// `init(step:save:onFinished:)` the previews use) and drives it through the real
/// SwiftUI view, so the step gating, unit toggles and completion wiring are
/// exercised. Content is asserted against the shared ``OnboardingTokens`` (never
/// hardcoded copy); the text-less back button is located by its accessibility
/// identifier. Mirrors the Android `OnboardingViewTest`.
///
/// The step is seeded rather than walked from the default entry point, the
/// closest iOS equivalent of the Android test's `setContent`.
///
/// ``OnboardingView`` takes its `@Observable` view model as an injected `let`
/// (owned by the app, not held in `@State`). View Inspector's `inspect()`
/// evaluates `body` on a detached struct copy, so with no `@State` to read
/// SwiftUI emits no "Accessing State ... without being installed" runtime
/// warning. `ViewHosting.host(view:)` still hosts the view so it renders
/// (exercising `@Observable` change tracking) while it is inspected.
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

    // MARK: - Gender & age

    func testGenderStepGatesContinueUntilAGenderIsChosen() throws {
        let view = OnboardingView(step: .gender)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.genderTitle)
        _ = try inspected.find(text: OnboardingTokens.genderSubtitle)
        XCTAssertTrue(try nextButton(inspected).isDisabled())

        // The carousel opens on the middle card (Male).
        try inspected.find(button: OnboardingTokens.genderOptions[1].label).tap()

        XCTAssertFalse(try nextButton(try view.inspect()).isDisabled())
    }

    func testGenderStepTogglesTheSelectedCardOff() throws {
        let view = OnboardingView(step: .gender)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let label = OnboardingTokens.genderOptions[1].label
        try view.inspect().find(button: label).tap()
        XCTAssertFalse(try nextButton(try view.inspect()).isDisabled())

        try view.inspect().find(button: label).tap()
        XCTAssertTrue(try nextButton(try view.inspect()).isDisabled())
    }

    func testGenderStepSkipAdvancesWithoutASelection() throws {
        let view = OnboardingView(step: .gender)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        XCTAssertTrue(try nextButton(inspected).isDisabled())

        try skipButton(inspected).tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: OnboardingTokens.ageTitle)
    }

    func testAgeStepShowsTheDefaultAndAdvances() throws {
        let view = OnboardingView(step: .age)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.ageTitle)
        _ = try inspected.find(text: "\(OnboardingTokens.ageDefault)")
        XCTAssertFalse(try nextButton(inspected).isDisabled())

        try nextButton(inspected).tap()

        let inspectedAgain = try view.inspect()
        _ = try inspectedAgain.find(text: OnboardingTokens.weightTitle)
    }

    func testAgeWheelTapSelectsAnAge() throws {
        let viewModel = OnboardingViewModel(step: .age)
        let view = OnboardingView(viewModel: viewModel)

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.ageTitle)
        XCTAssertEqual(viewModel.age, OnboardingTokens.ageDefault)

        // The neighbouring age is a plain tappable row (not a `Button`), so walk
        // up from its label to the view carrying the row's tap gesture.
        let nextAge = OnboardingTokens.ageDefault + 1
        var row = try inspected.find(text: "\(nextAge)").parent()
        for _ in 0..<6 {
            if (try? row.callOnTapGesture()) != nil { break }
            row = try row.parent()
        }

        XCTAssertEqual(viewModel.age, nextAge)
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
        let view = OnboardingView(step: .activity, save: { saved = $0 }) {
            finished = true
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
        let view = OnboardingView(step: .welcome, save: { saved.append($0) }) {
            finished += 1
        }

        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        // Welcome -> Goal
        let inspected = try view.inspect()
        _ = try inspected.find(text: OnboardingTokens.welcomeTitle)
        try nextButton(inspected).tap()

        // Goal -> Gender
        let inspected2 = try view.inspect()
        _ = try inspected2.find(text: OnboardingTokens.goalTitle)
        try inspected2.find(button: OnboardingTokens.goals[0].title).tap()
        try nextButton(try view.inspect()).tap()

        // Gender -> Age
        let inspected3 = try view.inspect()
        _ = try inspected3.find(text: OnboardingTokens.genderTitle)
        try inspected3.find(button: OnboardingTokens.genderOptions[1].label).tap()
        try nextButton(try view.inspect()).tap()

        // Age -> Weight
        let inspected4 = try view.inspect()
        _ = try inspected4.find(text: OnboardingTokens.ageTitle)
        _ = try inspected4.find(text: "\(OnboardingTokens.ageDefault)")
        try nextButton(try view.inspect()).tap()

        // Weight -> Height
        let inspected5 = try view.inspect()
        _ = try inspected5.find(text: OnboardingTokens.weightTitle)
        try nextButton(try view.inspect()).tap()

        // Height -> Activity
        let inspected6 = try view.inspect()
        _ = try inspected6.find(text: OnboardingTokens.heightTitle)
        try nextButton(try view.inspect()).tap()

        // Activity -> finish
        let inspected7 = try view.inspect()
        _ = try inspected7.find(text: OnboardingTokens.activityTitle)
        XCTAssertTrue(try nextButton(inspected7).isDisabled())
        try inspected7.find(button: OnboardingTokens.activityLevels[0].title).tap()
        try nextButton(try view.inspect()).tap()

        XCTAssertEqual(finished, 1)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.goal, OnboardingTokens.goals[0].title)
        XCTAssertEqual(saved.first?.sex, OnboardingTokens.genderOptions[1].value)
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

    /// The secondary skip pill, located by its identifier.
    private func skipButton(_ view: InspectableView<ViewType.ClassifiedView>) throws -> InspectableView<ViewType.Button> {
        try view.find(ViewType.Button.self) { button in
            try button.accessibilityIdentifier() == OnboardingAccessibility.skip
        }
    }
}
