import XCTest
@testable import Onboarding

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    func testStartsOnWelcomeStepWithDefaultUnits() {
        let viewModel = OnboardingViewModel()

        XCTAssertEqual(viewModel.step, .welcome)
        XCTAssertEqual(viewModel.weightUnit, OnboardingTokens.defaultWeightUnit)
        XCTAssertEqual(viewModel.heightUnit, OnboardingTokens.defaultHeightUnit)
        XCTAssertEqual(viewModel.weightDisplay, OnboardingTokens.weightKgDefault)
        XCTAssertEqual(viewModel.heightDisplay, OnboardingTokens.heightCmDefault)
        XCTAssertTrue(viewModel.isFirstStep)
        XCTAssertFalse(viewModel.isLastStep)
    }

    func testExposesFiveSteps() {
        let viewModel = OnboardingViewModel()

        XCTAssertEqual(viewModel.stepCount, 5)
        XCTAssertEqual(viewModel.stepIndex, 0)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .goal)
        XCTAssertEqual(viewModel.stepIndex, 1)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .profile)
        XCTAssertEqual(viewModel.stepIndex, 2)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .weight)
        XCTAssertEqual(viewModel.stepIndex, 3)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .height)
        XCTAssertEqual(viewModel.stepIndex, 4)
        XCTAssertTrue(viewModel.isLastStep)

        viewModel.back()
        XCTAssertEqual(viewModel.step, .weight)
    }

    func testStaysOnBounds() {
        let viewModel = OnboardingViewModel()

        viewModel.back()
        XCTAssertEqual(viewModel.step, .welcome)

        viewModel.next()
        viewModel.next()
        viewModel.next()
        viewModel.next()
        XCTAssertEqual(viewModel.step, .height)
    }

    func testSelectsASingleGoal() {
        let viewModel = OnboardingViewModel()

        XCTAssertFalse(viewModel.hasGoal)
        XCTAssertNil(viewModel.goal)

        viewModel.selectGoal("Gain muscle")
        XCTAssertEqual(viewModel.goal, "Gain muscle")
        XCTAssertTrue(viewModel.hasGoal)

        // Selecting another goal replaces the previous one (single-select).
        viewModel.selectGoal("Lose fat")
        XCTAssertEqual(viewModel.goal, "Lose fat")

        // Unknown titles are ignored.
        viewModel.selectGoal("Not a goal")
        XCTAssertEqual(viewModel.goal, "Lose fat")
    }

    func testStartsProfileWithDefaultAgeAndNoSex() {
        let viewModel = OnboardingViewModel()

        XCTAssertEqual(viewModel.age, OnboardingTokens.ageDefault)
        XCTAssertNil(viewModel.sex)
        XCTAssertFalse(viewModel.hasSex)

        viewModel.selectSex("Female")
        XCTAssertEqual(viewModel.sex, "Female")
        XCTAssertTrue(viewModel.hasSex)

        // Selecting another option replaces the previous one (single-select).
        viewModel.selectSex("Prefer not to say")
        XCTAssertEqual(viewModel.sex, "Prefer not to say")

        // Unknown options are ignored.
        viewModel.selectSex("Not an option")
        XCTAssertEqual(viewModel.sex, "Prefer not to say")

        viewModel.setAge(42)
        XCTAssertEqual(viewModel.age, 42)
    }

    func testSwitchingUnitPreservesTheMeasurement() {
        let viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("lb")
        XCTAssertEqual(viewModel.weightDisplay, 154)
        viewModel.selectWeightUnit("kg")
        XCTAssertEqual(viewModel.weightDisplay, 70)

        viewModel.selectHeightUnit("ft/in")
        XCTAssertEqual(viewModel.heightDisplay, 67)
        XCTAssertEqual(viewModel.heightDisplayText, "5'7\"")
        viewModel.selectHeightUnit("cm")
        XCTAssertEqual(viewModel.heightDisplay, 170)
        XCTAssertEqual(viewModel.heightDisplayText, "170")
    }

    func testFormatsImperialHeightAsFeetAndInches() {
        XCTAssertEqual(OnboardingViewModel.formatFtIn(47), "3'11\"")
        XCTAssertEqual(OnboardingViewModel.formatFtIn(60), "5'0\"")
        XCTAssertEqual(OnboardingViewModel.formatFtIn(67), "5'7\"")
        XCTAssertEqual(OnboardingViewModel.formatFtIn(87), "7'3\"")
    }

    func testIgnoresUnknownUnits() {
        let viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("stone")
        XCTAssertEqual(viewModel.weightUnit, OnboardingTokens.defaultWeightUnit)

        viewModel.selectHeightUnit("fathoms")
        XCTAssertEqual(viewModel.heightUnit, OnboardingTokens.defaultHeightUnit)
    }

    func testSetValueConvertsFromTheCurrentUnit() {
        let viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("lb")
        viewModel.setWeightDisplay(200)
        viewModel.selectWeightUnit("kg")
        XCTAssertEqual(viewModel.weightDisplay, OnboardingViewModel.lbToKg(200))

        viewModel.selectHeightUnit("ft/in")
        viewModel.setHeightDisplay(60)
        viewModel.selectHeightUnit("cm")
        XCTAssertEqual(viewModel.heightDisplay, OnboardingViewModel.inToCm(60))
    }

    func testConversionsRoundTrip() {
        XCTAssertEqual(OnboardingViewModel.lbToKg(OnboardingViewModel.kgToLb(70)), 70)
        XCTAssertEqual(OnboardingViewModel.inToCm(OnboardingViewModel.cmToIn(170)), 170)
    }
}
