import XCTest
@testable import Splash

final class SplashTokensTests: XCTestCase {

    func testFlowTimings() {
        XCTAssertEqual(SplashTokens.autoAdvanceBrandMs, 1200)
        XCTAssertEqual(SplashTokens.autoAdvanceWelcomeMs, 1200)
    }

    func testFlowFlags() {
        XCTAssertTrue(SplashTokens.showEveryLaunch)
        XCTAssertFalse(SplashTokens.showAuthActions)
        XCTAssertFalse(SplashTokens.showGuestLink)
        XCTAssertTrue(SplashTokens.showGuestButton)
    }

    func testCopy() {
        XCTAssertEqual(SplashTokens.titleLine1, "Start your")
        XCTAssertEqual(SplashTokens.titleLine2, "Fitness Journey")
        XCTAssertEqual(SplashTokens.login, "Login")
        XCTAssertEqual(SplashTokens.register, "Register")
        XCTAssertEqual(SplashTokens.guest, "Continue as a guest")
    }

    func testIconSize() {
        XCTAssertEqual(SplashTokens.iconSize, 96)
    }

    func testStagesMatchTheStageEnum() {
        XCTAssertEqual(SplashTokens.stages, [.brand, .welcome, .actions])
    }
}
