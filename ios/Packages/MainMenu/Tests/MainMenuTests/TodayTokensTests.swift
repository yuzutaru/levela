import XCTest
@testable import MainMenu

final class TodayTokensTests: XCTestCase {

    func testCopy() {
        XCTAssertEqual(TodayTokens.title, "Overview")
    }

    func testScreenTagStaysStable() {
        // The app-level UI tests assert on this exact string.
        XCTAssertEqual(TodayTokens.screenTag, "mainmenu.today")
    }
}
