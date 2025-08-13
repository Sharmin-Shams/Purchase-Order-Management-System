package com.example.codenb.ui.po



import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PurchaseOrderScreen(navController: NavHostController) {
    val viewModel: PurchaseOrderViewModel = viewModel(factory = PurchaseOrderViewModel.Factory)
    val uiState by viewModel.uiState.collectAsState()

    var expanded by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Home") },
                navigationIcon = {
                    IconButton(onClick = {
                        navController.navigate("home")
                    }) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back to Home"
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Text("Select Department", style = MaterialTheme.typography.titleMedium)
            Box {
                OutlinedTextField(
                    value = uiState.selectedDepartment?.name ?: "",
                    onValueChange = {},
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { expanded = true },
                    enabled = false,
                    label = { Text("Department") }
                )
                DropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false }
                ) {
                    uiState.departments.forEach { department ->
                        DropdownMenuItem(
                            onClick = {
                                viewModel.onDepartmentSelected(department)
                                expanded = false
                            },
                            text = { Text(department.name) }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = { viewModel.searchPOs() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Search Purchase Orders")
            }

            Spacer(modifier = Modifier.height(16.dp))

            uiState.feedbackMessage?.let {
                Text(it, color = Color.Red, style = MaterialTheme.typography.bodyMedium)
                Spacer(modifier = Modifier.height(8.dp))
            }

            LazyColumn {
                items(uiState.purchaseOrders) { po ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp)
                            .clickable {
                                navController.navigate("purchaseOrderDetail/${po.purchaseOrderNumber}")
                            },
                        elevation = CardDefaults.cardElevation(4.dp)
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Text("PO #: ${po.purchaseOrderNumber}", style = MaterialTheme.typography.titleSmall)
                            Text("Date: ${po.creationDate.split("T").first()}", style = MaterialTheme.typography.bodySmall)
                            Text("Supervisor: ${po.supervisorName}", style = MaterialTheme.typography.bodySmall)
                            Text("Status: ${po.purchaseOrderStatus}", style = MaterialTheme.typography.bodySmall)
                        }
                    }
                }
            }
        }
    }
}


