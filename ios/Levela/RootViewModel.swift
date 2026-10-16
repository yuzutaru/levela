import Foundation
import Observation
import Profile

/// Launch-time state machine: loading → ready | failed.
enum AppState {
    case loading
    case failed(String)
    case ready(AppContainer, hasProfile: Bool)
}

/// Owns the app's launch-time bootstrap: opening the profile store, building the
/// container, and resolving whether a profile already exists. The repository is
/// reached through this view model instead of being touched by the app shell.
@Observable
@MainActor
final class RootViewModel {
    private(set) var state: AppState = .loading

    func bootstrap() async {
        do {
            let profileData = try await ProfileData.open()
            let container = AppContainer(profileData: profileData)
            let hasProfile = try container.userProfileRepository.activeProfile() != nil
            state = .ready(container, hasProfile: hasProfile)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}