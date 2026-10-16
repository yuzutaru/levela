import XCTest
@testable import Splash

final class SplashStageTests: XCTestCase {

    func testRawValuesMatchContract() {
        XCTAssertEqual(SplashStage.brand.rawValue, "brand")
        XCTAssertEqual(SplashStage.welcome.rawValue, "welcome")
        XCTAssertEqual(SplashStage.actions.rawValue, "actions")
    }

    func testAllCasesMatchTokenOrder() {
        XCTAssertEqual(SplashStage.allCases, SplashTokens.stages)
    }
}
