import Profile
import XCTest
@testable import Levela

@MainActor
final class RootViewModelTests: XCTestCase {

    func testHasProfileIsNilUntilLoaded() {
        let viewModel = makeViewModel(stored: nil)

        XCTAssertNil(viewModel.hasProfile)
    }

    func testLoadResolvesFalseWhenNoProfileExists() {
        let viewModel = makeViewModel(stored: nil)

        viewModel.load()

        XCTAssertEqual(viewModel.hasProfile, false)
    }

    func testLoadResolvesTrueWhenAProfileAlreadyExists() {
        let viewModel = makeViewModel(stored: sampleUserProfile())

        viewModel.load()

        XCTAssertEqual(viewModel.hasProfile, true)
    }

    private func makeViewModel(stored: UserProfile?) -> RootViewModel {
        let useCase = HasActiveProfileUseCase(
            repository: FakeUserProfileRepository(stored: stored)
        )
        return RootViewModel(hasActiveProfileUseCase: useCase)
    }
}
