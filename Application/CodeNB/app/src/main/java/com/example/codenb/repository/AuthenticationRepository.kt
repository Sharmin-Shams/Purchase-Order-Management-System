package com.example.codenb.repository

import com.example.codenb.data.AuthService
import com.example.codenb.model.LoginDto
import com.example.codenb.model.LoginResultDto
import retrofit2.Response

interface AuthRepository {
    suspend fun login(loginRequest: LoginDto): Response<LoginResultDto>
}

class RemoteAuthRepository(
    private val authService: AuthService
) : AuthRepository {
    override suspend fun login(loginRequest: LoginDto): Response<LoginResultDto> {
        return authService.login(loginRequest)
    }
}