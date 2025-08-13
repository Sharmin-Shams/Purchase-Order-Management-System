import android.annotation.SuppressLint
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.example.codenb.model.DepartmentDto
import com.example.codenb.model.EmployeeSearchDto
import com.example.codenb.model.EmployeeSearchResultDto
import com.example.codenb.ui.employee_directory.EmployeeDirectoryViewModel
import com.example.codenb.ui.theme.primaryLight
import kotlinx.coroutines.launch

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun EmployeeDirectoryScreen(
    modifier: Modifier = Modifier,
    onEmployeeClick: (Int) -> Unit,
    viewModel: EmployeeDirectoryViewModel = viewModel(factory = EmployeeDirectoryViewModel.Factory),
) {
    val departments by viewModel.departmentsState.collectAsStateWithLifecycle()
    val employees by viewModel.employeesState.collectAsStateWithLifecycle()
    val isLoading by viewModel.isLoading.collectAsStateWithLifecycle()

    var selectedDepartment by remember { mutableStateOf<DepartmentDto?>(null) }
    var lastName by remember { mutableStateOf("") }
    var employeeNumber by remember { mutableStateOf("") }

    val error by viewModel.error.collectAsStateWithLifecycle()
    val hasSearched by viewModel.hasSearched.collectAsStateWithLifecycle()

    val snackbarHostState = remember { SnackbarHostState() }
    val coroutineScope = rememberCoroutineScope()

    LaunchedEffect(error) {
        error?.let {
            coroutineScope.launch {
                snackbarHostState.showSnackbar(it)
                viewModel.clearError()
            }
        }
    }

    LaunchedEffect(Unit) {
        viewModel.loadInitialData();
    }

    Scaffold(
        snackbarHost = {
            SnackbarHost(hostState = snackbarHostState)
        }
    ) {
        Card(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxSize(),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            shape = RoundedCornerShape(16.dp),
            elevation = CardDefaults.cardElevation(8.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(vertical = 24.dp)
            ) {
                Text(
                    text = "Employee Directory",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier
                        .padding(horizontal = 24.dp)
                        .padding(bottom = 16.dp)
                )

                EmployeeSearchForm(
                    departments = departments,
                    selectedDepartment = selectedDepartment,
                    onDepartmentSelected = { selectedDepartment = it },
                    lastName = lastName,
                    onLastNameChange = { lastName = it },
                    employeeNumber = employeeNumber,
                    onEmployeeNumberChange = { employeeNumber = it },
                    onSearch = {
                        viewModel.searchEmployees(
                            EmployeeSearchDto(
                                departmentID = selectedDepartment?.id,
                                lastName = lastName,
                                employeeID = employeeNumber
                            )
                        )
                    }
                )

                Spacer(Modifier.height(24.dp))

                if (!isLoading) {
                    EmployeeList(
                        employees,
                        hasSearched = hasSearched,
                        onEmployeeClick = onEmployeeClick
                    )
                } else {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.CenterHorizontally))
                }
            }
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun EmployeeSearchForm(
    departments: List<DepartmentDto>,
    selectedDepartment: DepartmentDto?,
    onDepartmentSelected: (DepartmentDto) -> Unit,
    lastName: String,
    onLastNameChange: (String) -> Unit,
    employeeNumber: String,
    onEmployeeNumberChange: (String) -> Unit,
    onSearch: () -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(horizontal = 24.dp)
    ) {
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            Card(
                elevation = CardDefaults.elevatedCardElevation(defaultElevation = 4.dp),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                TextField(
                    value = selectedDepartment?.name ?: "",
                    onValueChange = {},
                    label = { Text("Department", fontSize = 14.sp) },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
                    readOnly = true,
                    colors = TextFieldDefaults.colors(
                        focusedIndicatorColor = Color.Gray,
                        disabledTextColor = Color.Black,
                        disabledLabelColor = Color.Gray,
                        disabledTrailingIconColor = Color.Gray,
                        unfocusedIndicatorColor = Color.Gray,
                        focusedContainerColor = Color.White,
                        unfocusedContainerColor = Color.White,
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .menuAnchor(MenuAnchorType.PrimaryNotEditable, true)
                )
            }

            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                departments.forEach { department ->
                    DropdownMenuItem(
                        text = { Text(department.name) },
                        onClick = {
                            onDepartmentSelected(department)
                            expanded = false
                        }
                    )
                }
            }
        }

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = employeeNumber,
            onValueChange = onEmployeeNumberChange,
            singleLine = true,
            label = { Text("Employee number", fontSize = 14.sp) },
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(Modifier.height(8.dp))

        OutlinedTextField(
            value = lastName,
            onValueChange = onLastNameChange,
            singleLine = true,
            label = { Text("Last name", fontSize = 14.sp) },
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(Modifier.height(16.dp))

        val keyboardController = LocalSoftwareKeyboardController.current
        Button(modifier = Modifier.fillMaxWidth(),
            onClick = {
                keyboardController?.hide()
                onSearch()
            }) {
            Text("Search")
        }
    }
}

@Composable
fun EmployeeList(
    employees: List<EmployeeSearchResultDto>,
    hasSearched: Boolean,
    onEmployeeClick: (Int) -> Unit
) {
    if (hasSearched && employees.isEmpty()) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "No employee(s) found.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                textAlign = TextAlign.Center
            )
        }
    } else {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp)
        ) {
            items(employees) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .clickable {
                            onEmployeeClick(it.id)
                        },
                    elevation = CardDefaults.cardElevation(8.dp),
                ) {
                    EmployeeListItem(it)
                }
                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
fun EmployeeListItem(employee: EmployeeSearchResultDto) {
    Column(modifier = Modifier.padding(12.dp)) {
        Text(
            text = "${employee.lastName}, ${employee.firstName}",
            style = MaterialTheme.typography.bodyMedium
        )
        Text(
            text = employee.position,
            style = MaterialTheme.typography.bodySmall,
            color = primaryLight
        )
    }
}