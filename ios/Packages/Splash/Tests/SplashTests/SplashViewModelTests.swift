import XCTest
@testable import Splash

@MainActor
final class SplashViewModelTests: XCTestCase {

    func testStartsOnBrandStage() {
        let viewModel = SplashViewModel()

        XCTAssertEqual(viewModel.stage, .brand)
        XCTAssertFalse(viewModel.isFinished)
    }

    func testAdvancesThroughEveryStage() {
        let viewModel = SplashViewModel()

        viewModel.advance()
        XCTAssertEqual(viewModel.stage, .welcome)

        viewModel.advance()
        XCTAssertEqual(viewModel.stage, .actions)
        XCTAssertTrue(viewModel.isFinished)

        // Stays put once finished.
        viewModel.advance()
        XCTAssertEqual(viewModel.stage, .actions)
    }

    func testNextDelayFollowsTheContract() {
        let viewModel = SplashViewModel()

        XCTAssertEqual(viewModel.nextDelayMs, SplashTokens.autoAdvanceBrandMs)
        viewModel.advance()
        XCTAssertEqual(viewModel.nextDelayMs, SplashTokens.autoAdvanceWelcomeMs)
        viewModel.advance()
        XCTAssertNil(viewModel.nextDelayMs)
    }
}
