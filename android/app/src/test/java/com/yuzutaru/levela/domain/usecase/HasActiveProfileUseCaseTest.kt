package com.yuzutaru.levela.domain.usecase

import com.yuzutaru.levela.FakeUserProfileRepository
import com.yuzutaru.levela.sampleUserProfile
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class HasActiveProfileUseCaseTest {

    @Test
    fun emitsFalseBeforeOnboardingCompletes() = runTest {
        val useCase = HasActiveProfileUseCase(FakeUserProfileRepository())

        assertFalse(useCase().first())
    }

    @Test
    fun emitsTrueOnceAProfileExists() = runTest {
        val useCase = HasActiveProfileUseCase(
            FakeUserProfileRepository(stored = sampleUserProfile()),
        )

        assertTrue(useCase().first())
    }
}
