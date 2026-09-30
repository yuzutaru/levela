import Foundation
import Observation

/// Drives the onboarding flow.
///
/// `@Observable` + `@MainActor` is the iOS counterpart to the Android
/// `OnboardingViewModel`; the owning view holds it with `@State`.
@Observable
@MainActor
public final class OnboardingViewModel {
    public let pageCount: Int
    public private(set) var currentPage: Int

    public init(pageCount: Int = 3) {
        precondition(pageCount > 0, "Onboarding must have at least one page.")
        self.pageCount = pageCount
        self.currentPage = 0
    }

    public var isLastPage: Bool { currentPage >= pageCount - 1 }

    public func advance() {
        guard !isLastPage else { return }
        currentPage += 1
    }

    public func back() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
}
