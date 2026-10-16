//
//  LevelaApp.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Profile
import SwiftUI

@main
struct LevelaApp: App {
    init() {
        LevelaFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            AppBootstrapView()
        }
    }
}

/// Handles async store bootstrap and renders the appropriate UI.
private struct AppBootstrapView: View {
    @State private var state: AppState = .loading

    var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.blue500)
                .levelaTheme()
                .task { await bootstrap() }

        case .failed(let message):
            ErrorView(message: message) {
                Task { await bootstrap() }
            }
            .levelaTheme()

        case .ready(let container, let hasProfile):
            LevelaRootView(
                completeOnboardingUseCase: container.completeOnboardingUseCase,
                hasProfile: hasProfile
            )
        }
    }

    private func bootstrap() async {
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

/// Launch-time state machine: loading → ready | failed.
private enum AppState {
    case loading
    case ready(AppContainer, hasProfile: Bool)
    case failed(String)
}