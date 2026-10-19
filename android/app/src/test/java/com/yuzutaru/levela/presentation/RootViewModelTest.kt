package com.yuzutaru.levela.presentation

import com.yuzutaru.levela.FakeUserProfileRepository
import com.yuzutaru.levela.domain.usecase.HasActiveProfileUseCase
import com.yuzutaru.levela.sampleUserProfile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class RootViewModelTest {

    private val mainDispatcher: TestDispatcher = StandardTestDispatcher()

    @Before
    fun setUp() {
        Dispatchers.setMain(mainDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun hasProfileIsNullUntilCollected() = runTest(mainDispatcher) {
        val viewModel = RootViewModel(HasActiveProfileUseCase(FakeUserProfileRepository()))

        assertNull(viewModel.hasProfile.value)
    }

    @Test
    fun resolvesFalseWhenNoProfileExists() = runTest(mainDispatcher) {
        val viewModel = RootViewModel(HasActiveProfileUseCase(FakeUserProfileRepository()))

        backgroundScope.launch { viewModel.hasProfile.collect { } }
        advanceUntilIdle()

        assertEquals(false, viewModel.hasProfile.value)
    }

    @Test
    fun resolvesTrueWhenAProfileAlreadyExists() = runTest(mainDispatcher) {
        val viewModel = RootViewModel(
            HasActiveProfileUseCase(FakeUserProfileRepository(stored = sampleUserProfile())),
        )

        backgroundScope.launch { viewModel.hasProfile.collect { } }
        advanceUntilIdle()

        assertEquals(true, viewModel.hasProfile.value)
    }
}
