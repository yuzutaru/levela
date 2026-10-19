import Profile
import XCTest
@testable import Levela

@MainActor
final class HasActiveProfileUseCaseTests: XCTestCase {

    func testReturnsFalseWhenNoProfileExists() {
        let useCase = HasActiveProfileUseCase(repository: FakeUserProfileRepository())

        XCTAssertFalse(useCase.invoke())
    }

    func testReturnsTrueOnceAProfileExists() {
        let useCase = HasActiveProfileUseCase(
            repository: FakeUserProfileRepository(stored: sampleUserProfile())
        )

        XCTAssertTrue(useCase.invoke())
    }
}
