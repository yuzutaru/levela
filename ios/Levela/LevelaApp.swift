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
    /// The app's dependency graph; built once at launch.
    private let container: AppContainer

    init() {
        // Fonts live in the Design package's resource bundle; register them so
        // `Font.custom` can resolve their PostScript names.
        LevelaFonts.registerAll()
        // The offline-first store for the user's profile. Rows stay guest-owned
        // until the user registers, then sync under the account.
        container = try! AppContainer()
    }

    var body: some Scene {
        WindowGroup {
            LevelaRootView(completeOnboardingUseCase: container.completeOnboardingUseCase)
        }
    }
}
