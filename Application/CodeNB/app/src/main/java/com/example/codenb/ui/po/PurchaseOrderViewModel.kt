package com.example.codenb.ui.po

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.example.codenb.MyApp
import com.example.codenb.model.DepartmentDto
import com.example.codenb.model.PurchaseOrderDetails
import com.example.codenb.model.PurchaseOrderSummary
import com.example.codenb.repository.PurchaseOrderRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class PurchaseOrderViewModel(private  val repository: PurchaseOrderRepository): ViewModel(){
    private val _uiState = MutableStateFlow(PurchaseOrderUiState())
    val uiState: StateFlow<PurchaseOrderUiState> = _uiState.asStateFlow()

    init {
        loadDepartments()
    }

    private fun loadDepartments() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, feedbackMessage = null) }
            try {
                val response = repository.getDepartments()
                if (response.isSuccessful) {
                    _uiState.update { it.copy(departments = response.body() ?: emptyList()) }
                } else {
                    _uiState.update { it.copy(feedbackMessage = "Failed to load departments: ${response.code()}") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(feedbackMessage = "Failed to load departments.") }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }
    fun onDepartmentSelected(dept: DepartmentDto) {
        _uiState.update { it.copy(selectedDepartment = dept) }
    }
    fun searchPOs() {
        val dept = _uiState.value.selectedDepartment
        if (dept == null) {
            _uiState.update { it.copy(feedbackMessage = "Please select a department.") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, feedbackMessage = null) }
            try {
                val response = repository.searchPurchaseOrders(dept.id)
                if (response.isSuccessful) {
                    val result = response.body() ?: emptyList()
                    _uiState.update {
                        it.copy(
                            purchaseOrders = result,
                            feedbackMessage = if (result.isEmpty()) "No purchase orders found." else null
                        )
                    }
                } else {
                    _uiState.update { it.copy(feedbackMessage = "Failed to fetch POs: ${response.code()}") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(feedbackMessage = "Error searching purchase orders.") }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    fun viewDetails(poNumber: String) {
        viewModelScope.launch {
            try {
                val poInt = poNumber.toIntOrNull() ?: return@launch
                val response = repository.getPurchaseOrderDetails(poInt)
                if (response.isSuccessful) {
                    val po = response.body()
                    val itemCount = po?.items?.count { !it.itemStatus.equals("Denied", ignoreCase = true) } ?: 0
                    _uiState.update { it.copy(selectedPO = po, itemCount = itemCount) }
                } else {
                    _uiState.update { it.copy(feedbackMessage = "Failed to load PO: ${response.code()}") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(feedbackMessage = "Error loading PO details.") }
            }
        }
    }

    fun goBack() {
        _uiState.update { it.copy(selectedPO = null) }
    }

    companion object {
        val Factory: ViewModelProvider.Factory = viewModelFactory {
            initializer {
                val app = (this[ViewModelProvider.AndroidViewModelFactory.APPLICATION_KEY] as MyApp)
                val repo = app.container.purchaseOrderRepository
                PurchaseOrderViewModel(repo)
            }
        }
    }

}

data class PurchaseOrderUiState(
    val departments: List<DepartmentDto> = emptyList(),
    val selectedDepartment: DepartmentDto? = null,
    val purchaseOrders: List<PurchaseOrderSummary> = emptyList(),
    val selectedPO: PurchaseOrderDetails? = null,
    val itemCount: Int = 0,
    val feedbackMessage: String? = null,
    val isLoading: Boolean = false
)