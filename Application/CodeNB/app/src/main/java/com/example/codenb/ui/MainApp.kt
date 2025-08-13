package com.example.codenb.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.codenb.ui.home.HomeScreen
import com.example.codenb.ui.home.HomeViewModel
import com.example.codenb.ui.login.LoginScreen
import com.example.codenb.ui.po.PurchaseOrderDetailScreen
import com.example.codenb.ui.po.PurchaseOrderScreen
import com.example.codenb.ui.splash.SplashScreen

@Composable
fun MainApp(
    navController: NavHostController = rememberNavController()
) {
    Scaffold { innerPadding ->
        Surface(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize(),
            color = Color.White
        ) {
            NavHost(
                navController = navController,
                startDestination = "splash"
            ) {
                composable("splash") {
                    SplashScreen(
                        onNavigateTo = { route ->
                            navController.navigate(route) {
                                popUpTo("splash") { inclusive = true }
                            }
                        }
                    )
                }
                composable(route = "login") {
                    LoginScreen(
                        onLoginSuccess = {
                            navController.navigate("home") {
                                popUpTo("login") { inclusive = true }
                            }
                        }
                    )
                }
                composable(route = "home") {
                    HomeScreen(
                        onLogoutSuccess = {
                            navController.navigate("login") {
                                popUpTo("home") { inclusive = true }
                            }
                        }
                    )
                }
            }
        }
    }
}