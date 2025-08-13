package com.example.codenb.ui.login

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.example.codenb.MyApp
import com.example.codenb.data.TokenManager
import com.example.codenb.model.ApiResponse
import com.example.codenb.model.LoginDto
import com.example.codenb.repository.AuthRepository
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

data class LoginUiState(
    val username: String = "",
    val password: String = "",
    val errorMessage: String? = null,
    val isLoading: Boolean = false,
    val isLoggedIn: Boolean = false
)

class LoginViewModel(
    private val authRepository: AuthRepository,
    private val tokenManager: TokenManager
) : ViewModel() {

    //Holds the current mutable UI state.
    private val _uiState = MutableStateFlow(LoginUiState())

    //The UI will collect this to observe changes. (readonly) Observable
    val uiState: StateFlow<LoginUiState> = _uiState

    fun onUsernameChanged(newUserName: String) {
        _uiState.update { it.copy(username = newUserName) }
    }

    fun onPasswordChanged(newPassword: String) {
        _uiState.update { it.copy(password = newPassword) }
    }

    private val _loginSuccessEvent = Channel<Unit>() //event emitter
    val loginSuccessEvent = _loginSuccessEvent.receiveAsFlow()

    fun login() {
        viewModelScope.launch {
            try {
                _uiState.update { it.copy(isLoading = true, errorMessage = null) }

                val request = LoginDto(
                    username = _uiState.value.username,
                    password = _uiState.value.password
                )

                delay(2000)

                if (request.username.length != 8) {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            errorMessage = "Invalid login."
                        )
                    }
                } else {

                    val response = authRepository.login(request)

                    if (response.isSuccessful) {
                        // Unwrap the successful response body
                        val loginResponse = response.body()

                        if (loginResponse != null) {
                            // Save the token if it's present
                            tokenManager.saveAuth(loginResponse)
                            _uiState.update { it.copy(isLoggedIn = true, isLoading = false) }
                            _loginSuccessEvent.send(Unit) // 👈 trigger success event
                            Log.d("token", loginResponse.token)

                        } else {
                            // If the login is unsuccessful, try to parse the error body
                            val errorBody =
                                response.errorBody()?.string() // Get the raw error response body
                            val errorResponse = parseError(errorBody)

                            _uiState.update {
                                it.copy(
                                    isLoading = false,
                                    errorMessage = errorResponse?.message ?: "An error occurred."
                                )
                            }
                        }

                    } else {
                        _uiState.update {
                            it.copy(
                                isLoading = false,
                                errorMessage = "Invalid login."
                            )
                        }
                    }
                }

            } catch (e: Exception) {
                e.message?.let { Log.e("token", it) }

                _uiState.update {
                    it.copy(
                        isLoggedIn = false, isLoading = false,
                        errorMessage = "Login Failed. Please try again."
                    )
                }
            }
        }
    }

    private val _logoutEvent = Channel<Unit>()
    val logoutEvent = _logoutEvent.receiveAsFlow()


    private fun parseError(errorBody: String?): ApiResponse? {
        return try {
            val json = Json { ignoreUnknownKeys = true }
            json.decodeFromString<ApiResponse>(errorBody ?: "")
        } catch (e: Exception) {
            null
        }
    }


    companion object {
        val Factory: ViewModelProvider.Factory = viewModelFactory {
            initializer {
                // 1. Get your Application instance
                val application = (this[APPLICATION_KEY] as MyApp)

                // 2. Access AppContainer to get dependencies
                val authRepository = application.container.authRepository
                val tokenManager = TokenManager(application.applicationContext)

                // 3. Pass them into the ViewModel constructor
                LoginViewModel(
                    authRepository = authRepository,
                    tokenManager = tokenManager
                )
            }
        }
    }
}