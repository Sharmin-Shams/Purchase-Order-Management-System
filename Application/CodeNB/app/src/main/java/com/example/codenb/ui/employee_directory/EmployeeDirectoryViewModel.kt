package com.example.codenb.ui.employee_directory

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.example.codenb.MyApp
import com.example.codenb.model.DepartmentDto
import com.example.codenb.model.EmployeeDetailsResultDto
import com.example.codenb.model.EmployeeSearchDto
import com.example.codenb.model.EmployeeSearchResultDto
import com.example.codenb.repository.DepartmentRepository
import com.example.codenb.repository.EmployeeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class EmployeeDetailsUiState(
    val isLoading: Boolean = false,
    val employee: EmployeeDetailsResultDto? = null,
    val error: String? = null
)

class EmployeeDirectoryViewModel(
    private val deptRepository: DepartmentRepository,
    private val empRepository: EmployeeRepository
) : ViewModel() {

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading

    private val _departmentsState = MutableStateFlow<List<DepartmentDto>>(emptyList())
    val departmentsState: StateFlow<List<DepartmentDto>> = _departmentsState

    private val _employeesState = MutableStateFlow<List<EmployeeSearchResultDto>>(emptyList())
    val employeesState: StateFlow<List<EmployeeSearchResultDto>> = _employeesState

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error

    private val _hasSearched = MutableStateFlow<Boolean>(false)
    val hasSearched: StateFlow<Boolean> = _hasSearched

    private val _uiState = MutableStateFlow(EmployeeDetailsUiState())
    val uiState: StateFlow<EmployeeDetailsUiState> = _uiState


    fun loadInitialData() {
        loadDepartments()
    }

    fun loadEmployee(id: Int?) {
        if (id == null) _uiState.value =
            EmployeeDetailsUiState(error = "Employee details not found.")
        else
            getEmployee(id.toString().padStart(8, '0'))
    }

    private fun getEmployee(id: String) {
        viewModelScope.launch {
            _uiState.value = EmployeeDetailsUiState(isLoading = true)
            try {
                val response = empRepository.getEmployee(id)
                if (response.isSuccessful) {
                    val employee = response.body()
                    if (employee != null)
                        _uiState.update { it.copy(employee = employee) }
                    else
                        _uiState.update { it.copy(error = "Employee details not found.") }
                } else {
                    _uiState.update { it.copy(employee = null, error = "Unknown error occurred.") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(employee = null, error = "Unknown error occurred.") }

            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }

    }

    fun searchEmployees(query: EmployeeSearchDto) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            _hasSearched.value = true;

            try {
                val response = empRepository.searchEmployees(query)

                if (response.isSuccessful) {
                    val employees = response.body()
                    if (employees.isNullOrEmpty())
                        _employeesState.value = emptyList()
                    else
                        _employeesState.value = employees

                } else {
                    _error.value = response.errorBody()?.string() ?: "Unknown error occurred"
                    _employeesState.value = emptyList();
                }

            } catch (e: Exception) {
                _employeesState.value = emptyList()
                _error.value = "Unknown error occurred"

            } finally {
                _isLoading.value = false
            }
        }
    }

    fun clearError() {
        _error.value = null
    }

    private fun loadDepartments() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = deptRepository.getDepartments()

                if (response.isSuccessful) {
                    val departments = response.body()
                    if (!departments.isNullOrEmpty())
                        _departmentsState.value = departments
                    else
                        _departmentsState.value = emptyList();

                } else {
                    _error.value = "There was a problem loading departments"
                    _departmentsState.value = emptyList()
                }

            } catch (e: Exception) {
                _error.value = "Unknown error occurred"
                _departmentsState.value = emptyList()
            } finally {
                _isLoading.value = false
            }
        }
    }

    companion object {
        val Factory: ViewModelProvider.Factory = viewModelFactory {
            initializer {
                val application = (this[APPLICATION_KEY] as MyApp)
                val deptRepository = application.container.deptRepository
                val empRepository = application.container.empRepository
                EmployeeDirectoryViewModel(
                    deptRepository = deptRepository,
                    empRepository = empRepository
                )
            }
        }
    }
}