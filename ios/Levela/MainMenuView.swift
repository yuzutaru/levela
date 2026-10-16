//
//  MainMenuView.swift
//  Levela
//

import Design
import SwiftUI

/// A placeholder home screen.
///
/// Stands in for the real main menu while it is built out: a blank, themed screen
/// with a centered "MainMenu" label, so the splash → onboarding → home navigation
/// can be verified end to end. Replace this with the real menu later. Mirrors the
/// Android `MainMenuScreen`.
struct MainMenuView: View {
    @Environment(\.levelaColors) private var colors

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            Text("MainMenu")
                .font(LevelaTypography.headlineMedium)
                .foregroundStyle(colors.onBackground)
                .accessibilityIdentifier(MainMenuAccessibility.title)
        }
    }
}

/// Stable accessibility handles for the mock home screen. The app's UI tests
/// repeat these strings — a UI-test bundle runs out of process and cannot import
/// the app target — so keep the two in sync.
enum MainMenuAccessibility {
    static let title = "mainmenu.title"
}

#Preview {
    MainMenuView()
        .levelaTheme()
}
