import XCTest
@testable import MainMenu

final class NutritionTokensTests: XCTestCase {

    func testCopy() {
        XCTAssertEqual(NutritionTokens.title, "Nutrition")
    }

    func testScreenTagStaysStable() {
        // The app-level UI tests assert on this exact string.
        XCTAssertEqual(NutritionTokens.screenTag, "mainmenu.nutrition")
    }
}
