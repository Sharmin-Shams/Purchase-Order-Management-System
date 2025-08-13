package com.example.codenb.ui.splash

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.codenb.R
import com.example.codenb.ui.theme.primaryDark
import com.example.codenb.ui.theme.primaryLight
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onNavigateTo: (String) -> Unit,
    viewModel: SplashViewModel = viewModel(factory = SplashViewModel.Factory),
) {
    val isLoggedIn by viewModel.isLoggedIn.collectAsState()

    LaunchedEffect(isLoggedIn) {
        if (isLoggedIn != null) {
            delay(1200)
            onNavigateTo(if (isLoggedIn == true) "home" else "login")
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(color = primaryLight)
            .systemBarsPadding(),

        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {

            Image(
                painter = painterResource(id = R.drawable.logo),
                contentDescription = "CodeNB logo"
            )
            Spacer(Modifier.height(16.dp))
            CircularProgressIndicator(color = Color.White)
        }
    }
}