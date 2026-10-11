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

    func testExposesThreeSteps() {
        let viewModel = OnboardingViewModel()

        XCTAssertEqual(viewModel.stepCount, 3)
        XCTAssertEqual(viewModel.stepIndex, 0)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .weight)
        XCTAssertEqual(viewModel.stepIndex, 1)

        viewModel.next()
        XCTAssertEqual(viewModel.step, .height)
        XCTAssertEqual(viewModel.stepIndex, 2)
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
        XCTAssertEqual(viewModel.step, .height)
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
