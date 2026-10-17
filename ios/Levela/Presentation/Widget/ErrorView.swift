//
//  ErrorView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import SwiftUI

/// A fallback screen shown when the persistent store fails to open.
/// Provides a Retry button to attempt recovery without restarting the app.
struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ZStack {
            Color.navy900.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange500)

                VStack(spacing: 8) {
                    Text("Couldn't load your data")
                        .font(LevelaTypography.headlineMedium)
                        .foregroundColor(.ink100)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(LevelaTypography.bodyMedium)
                        .foregroundColor(.gray400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button(action: retry) {
                    Text("Try again")
                        .font(LevelaTypography.labelLarge)
                        .foregroundColor(.ink100)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue500)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 48)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    ErrorView(message: "The database file appears to be corrupted or the disk is full.") {
        print("Retry tapped")
    }
    .levelaTheme()
}