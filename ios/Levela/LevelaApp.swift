//
//  LevelaApp.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
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
    @State private var viewModel = RootViewModel()

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.blue500)
                .levelaTheme()
                .task { await viewModel.bootstrap() }

        case .failed(let message):
            ErrorView(message: message) {
                Task { await viewModel.bootstrap() }
            }
            .levelaTheme()

        case .ready(let container, let hasProfile):
            LevelaRootView(
                completeOnboardingUseCase: container.completeOnboardingUseCase,
                hasProfile: hasProfile
            )
        }
    }
}