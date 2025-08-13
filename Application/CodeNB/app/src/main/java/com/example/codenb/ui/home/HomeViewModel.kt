package com.example.codenb.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.example.codenb.MyApp
import com.example.codenb.data.TokenManager
import com.example.codenb.model.UserInfo
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch

class HomeViewModel(
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _logoutEvent = MutableSharedFlow<Unit>()
    val logoutEvent = _logoutEvent.asSharedFlow()

    fun logout() {
        tokenManager.clearToken()
        viewModelScope.launch {
            _logoutEvent.emit(Unit)
        }
    }

    fun getUserInfo(): UserInfo? {
        return tokenManager.getName()?.let {
            UserInfo(
                name = it,
                role = tokenManager.getRole()!!
            )
        }
    }

    fun isSupervisor(): Boolean {
        var role = tokenManager.getRole()
        val supervisorRoles = listOf("CEO", "HRSupervisor", "RegularSupervisor")
        return supervisorRoles.any { it.equals(role, ignoreCase = true) }
    }

    companion object {
        val Factory: ViewModelProvider.Factory = viewModelFactory {
            initializer {
                val application = (this[APPLICATION_KEY] as MyApp)
                val tokenManager = TokenManager(application.applicationContext)
                HomeViewModel(tokenManager = tokenManager)
            }
        }
    }
}