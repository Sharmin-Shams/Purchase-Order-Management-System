package com.example.codenb.ui.home

import EmployeeDirectoryScreen
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.automirrored.outlined.List
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.codenb.model.UserInfo
import com.example.codenb.ui.employee_directory.EmployeeDetailScreen
import com.example.codenb.ui.po.PurchaseOrderDetailScreen
import com.example.codenb.ui.po.PurchaseOrderScreen

@Composable
fun HomeScreen(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
    viewModel: HomeViewModel = viewModel(factory = HomeViewModel.Factory),
    onLogoutSuccess: () -> Unit,
) {
    val user = viewModel.getUserInfo()

    LaunchedEffect(Unit) {
        viewModel.logoutEvent.collect {
            onLogoutSuccess()
        }
    }

    Scaffold(
        bottomBar = {
            NavigationBar(navController, viewModel)
        }
    ) { values ->
        Surface(
            color = MaterialTheme.colorScheme.background,
            modifier = Modifier
                .padding(
                    start = values.calculateStartPadding(LayoutDirection.Ltr),
                    end = values.calculateEndPadding(LayoutDirection.Ltr),
                    bottom = values.calculateBottomPadding()
                )
                .fillMaxSize()
        ) {
            NavHost(navController, startDestination = "home") {
                composable("home") {
                    HomeContent(user, viewModel)
                }
                composable("directory") {
                    EmployeeDirectoryScreen(
                        modifier,
                        onEmployeeClick = { employeeId ->
                            navController.navigate("employeeDetail/$employeeId")
                        })
                }
                composable(
                    "employeeDetail/{id}",
                    arguments = listOf(navArgument("id") { type = NavType.IntType })
                ) {
                    val id = it.arguments?.getInt("id")
                    id?.let {
                        EmployeeDetailScreen(
                            employeeId = id,
                            onBackPressed = { navController.popBackStack() }
                        )
                    }
                }

                composable("purchaseOrder") {
                    PurchaseOrderScreen(navController)
                }
                composable(
                    route = "purchaseOrderDetail/{poNumber}",
                    arguments = listOf(navArgument("poNumber") { type = NavType.StringType })
                ) {
                    val poNumber = it.arguments?.getString("poNumber") ?: ""
                    PurchaseOrderDetailScreen(poNumber = poNumber, navController = navController)
                }
            }
        }
    }
}

@Composable
private fun NavigationBar(navController: NavHostController, vm: HomeViewModel) {
    var selectedItem by remember { mutableIntStateOf(0) }
    val items = listOf("Home", "Directory", "Purchase Orders")

    val selectedIcons = listOf(
        Icons.Filled.Home,
        Icons.Filled.Search,
        Icons.AutoMirrored.Filled.List,
        Icons.Filled.AccountCircle
    )
    val unselectedIcons =
        listOf(
            Icons.Outlined.Home,
            Icons.Outlined.Search,
            Icons.AutoMirrored.Outlined.List,
            Icons.Outlined.AccountCircle
        )
    NavigationBar(containerColor = Color.White) {
        items.forEachIndexed { index, item ->
            if (item.equals("Purchase Orders", ignoreCase = true) && !vm.isSupervisor()) {
                return@forEachIndexed
            }

            NavigationBarItem(
                icon = {
                    Icon(
                        if (selectedItem == index) selectedIcons[index] else unselectedIcons[index],
                        contentDescription = item
                    )
                },
                label = { Text(item) },
                selected = selectedItem == index,
                onClick = {
                    selectedItem = index

                    when (index) {
                        0 -> navController.navigate("home")
                        1 -> navController.navigate("directory")
                        2 -> navController.navigate("purchaseOrder")
                        //  3 -> navController.navigate("profile")
                    }
                }
            )
        }
    }

}

@Composable
private fun HomeContent(
    user: UserInfo?,
    viewModel: HomeViewModel,
    modifier: Modifier = Modifier
) {

    Column(
        modifier = modifier
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {

        Text(text = "Hi there, ${user?.name}!")
        Text(text = "Role: ${user?.role}")

        Button(
            onClick = {
                viewModel.logout()
            }
        ) {
            Text(text = "Logout")
        }
    }
}