package com.example.codenb.ui.po

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PurchaseOrderDetailScreen(
    poNumber: String,
    navController: NavHostController,
    viewModel: PurchaseOrderViewModel = viewModel(factory = PurchaseOrderViewModel.Factory)
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(poNumber) {
        viewModel.viewDetails(poNumber)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Purchase Order Detail") },
                navigationIcon = {
                    IconButton(onClick = {
                        viewModel.goBack()
                        navController.popBackStack()
                    }) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            horizontalAlignment = Alignment.Start
        ) {
            uiState.selectedPO?.let { selectedPO ->
                Text("PO Number: ${selectedPO.purchaseOrderNumber.toString().padStart(8, '0')}")
                Text("Supervisor: ${selectedPO.supervisorFullName}")
                Text("Status: ${selectedPO.purchaseStatus}")
                Text("Grand Total: ${selectedPO.grandTotal}")
                Text("Total Items: ${uiState.itemCount}")
            }
        }
    }
}