import Foundation
import Observation
import Profile

/// Owns the app's launch-time state: whether a profile already exists.
///
/// The repository stays inside the view model instead of being touched directly
/// by the root view. `nil` means "still loading", `false` means "no profile yet"
/// (route to onboarding) and `true` means "returning user" (route to main menu).
/// Mirrors the Android `RootViewModel`.
@Observable
@MainActor
final class RootViewModel {
    private let repository: UserProfileRepository

    /// The launch-time profile state; `nil` until the check completes.
    private(set) var hasProfile: Bool?

    init(repository: UserProfileRepository) {
        self.repository = repository
    }

    /// Resolves whether a profile already exists. Called once from the root
    /// view's `.task` (the counterpart of Android's `stateIn` flow collection).
    func load() {
        hasProfile = (try? repository.activeProfile()) != nil
    }
}
