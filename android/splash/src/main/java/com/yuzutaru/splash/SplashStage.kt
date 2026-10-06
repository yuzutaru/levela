package com.yuzutaru.splash

/**
 * The auto-advancing stages of the splash flow.
 *
 * Mirrors the iOS `SplashStage`. The stage names must match
 * `flow.stages` in `assets/splash/splash-contract.json`
 * (enforced by `scripts/verify_splash_parity.sh`).
 */
enum class SplashStage {
    Brand,
    Welcome,
    Actions,
}
