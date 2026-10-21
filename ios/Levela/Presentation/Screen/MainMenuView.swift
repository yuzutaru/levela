//
//  MainMenuView.swift
//  Levela
//

import Design
import Splash
import SwiftUI
import Today

/// The app's bottom-navigation destinations, in left-to-right order.
///
/// Each destination is still a placeholder — a blank, themed screen with a large
/// centered title — until the real feature screens land. The navigation shell
/// itself is final. Mirrors the Android `MainMenuTab`.
enum MainMenuTab: String, CaseIterable, Identifiable {
    case today
    case nutrition
    case train
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .nutrition: "Nutrition"
        case .train: "Train"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "house.fill"
        case .nutrition: "fork.knife"
        case .train: "dumbbell.fill"
        case .profile: "person.fill"
        }
    }
}

/// Stable accessibility handles for the main menu. The app's UI tests repeat
/// these strings — a UI-test bundle runs out of process and cannot import the app
/// target — so keep the two in sync.
enum MainMenuAccessibility {
    static let today = "mainmenu.today"
    static let nutrition = "mainmenu.nutrition"
    static let train = "mainmenu.train"
    static let profile = "mainmenu.profile"
}

extension MainMenuTab {
    var accessibilityIdentifier: String {
        switch self {
        case .today: MainMenuAccessibility.today
        case .nutrition: MainMenuAccessibility.nutrition
        case .train: MainMenuAccessibility.train
        case .profile: MainMenuAccessibility.profile
        }
    }
}

/// The post-onboarding main menu: a native bottom tab bar over four
/// destinations, sharing the splash-style background. Today is the landing
/// destination. Mirrors the Android `MainMenuScreen`.
struct MainMenuView: View {
    @Environment(\.levelaColors) private var colors
    @State private var selection: MainMenuTab = .today

    var body: some View {
        TabView(selection: $selection) {
            ForEach(MainMenuTab.allCases) { tab in
                MainMenuDestination(tab: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
        .tint(colors.primary)
        .toolbarBackground(Color.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

/// The splash-style background shared by every main-menu destination: a white →
/// light-blue vertical gradient with a radial glow at the top.
struct MainMenuBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: SplashTokens.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [SplashTokens.backgroundGlow.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: -0.08),
                startRadius: 0,
                endRadius: 460
            )
        }
        .ignoresSafeArea()
    }
}

/// The destination content: the Today screen, or a placeholder for the tabs
/// whose real screens have not landed yet. The splash-style background is
/// applied per destination because `TabView` hosts each page opaquely.
private struct MainMenuDestination: View {
    let tab: MainMenuTab

    var body: some View {
        ZStack {
            MainMenuBackground()

            switch tab {
            case .today:
                TodayView()
            default:
                PlaceholderDestination(tab: tab)
            }
        }
    }
}

/// The blank placeholder for a destination, differentiated by its big title.
private struct PlaceholderDestination: View {
    let tab: MainMenuTab

    var body: some View {
        Text(tab.title)
            .font(LevelaTypography.displaySmall)
            .foregroundStyle(SplashTokens.title)
            .accessibilityIdentifier(tab.accessibilityIdentifier)
    }
}

#Preview {
    MainMenuView()
        .levelaTheme()
}
