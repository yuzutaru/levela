//
//  LevelaApp.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Profile
import SwiftData
import SwiftUI

@main
struct LevelaApp: App {
    init() {
        // Fonts live in the Design package's resource bundle; register them so
        // `Font.custom` can resolve their PostScript names.
        LevelaFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            LevelaRootView()
        }
        // The offline-first store for the user's profile. Rows stay guest-owned
        // until the user registers, then sync under the account.
        .modelContainer(for: UserProfile.self)
    }
}
