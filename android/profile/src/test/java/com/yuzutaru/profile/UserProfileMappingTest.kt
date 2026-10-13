package com.yuzutaru.profile

import com.yuzutaru.profile.local.SyncState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Test

class UserProfileMappingTest {

    @Test
    fun newRowsArePendingAndNotDeleted() {
        val entity = sampleProfile().toEntity(SyncState.Pending)

        assertEquals(SyncState.Pending, entity.syncState)
        assertFalse(entity.deleted)
    }

    @Test
    fun roundTripsThroughTheEntity() {
        val profile = sampleProfile()
        val entity = profile.toEntity(SyncState.Synced)

        assertEquals(profile, entity.toDomain())
    }

    @Test
    fun aGuestProfileHasNoAccount() {
        val profile = sampleProfile()

        assertNull(profile.accountUserId)
        assertNull(profile.toEntity(SyncState.Pending).accountUserId)
    }

    private fun sampleProfile() = UserProfile(
        id = "8a1b-uuid",
        accountUserId = null,
        goal = "Lose fat",
        ageYears = 30,
        sex = "Female",
        weightKg = 70.5,
        heightCm = 170.0,
        activityLevel = "Moderately active",
        weightUnit = "kg",
        heightUnit = "cm",
        onboardingCompleted = true,
        createdAt = 1_000L,
        updatedAt = 2_000L,
    )
}
