package com.yuzutaru.levela

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.ui.res.painterResource
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.splash.SplashView

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            LevelaTheme {
                // The splash is the app's launch screen. It reports completion
                // through `onFinished`; navigation will be wired here later.
                SplashView(
                    icon = painterResource(R.drawable.ic_launcher_foreground),
                )
            }
        }
    }
}
