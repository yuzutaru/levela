//
//  ProfileMapping.swift
//  Levela
//

import Foundation
import Onboarding
import Persistence

extension UserProfile {
    /// Builds a guest-owned profile (no account yet) from the collected
    /// onboarding values.
    ///
    /// The row gets a client-generated UUID: the same id the backend will later
    /// upsert, so registering can re-parent this row instead of copying it.
    convenience init(onboarding profile: OnboardingProfile) {
        let now = Date()
        self.init(
            id: UUID().uuidString,
            accountUserId: nil,
            goal: profile.goal,
            ageYears: profile.ageYears,
            sex: profile.sex,
            weightKg: profile.weightKg,
            heightCm: profile.heightCm,
            activityLevel: profile.activityLevel,
            weightUnit: profile.weightUnit,
            heightUnit: profile.heightUnit,
            onboardingCompleted: true,
            createdAt: now,
            updatedAt: now,
            syncState: .pending,
            deleted: false
        )
    }
}
