package com.example.codenb.model

import kotlinx.serialization.Serializable

@Serializable
data class LoginResultDto(
    val id: Int,
    val lastName: String,
    val firstName: String,
    val role: String,
    val token: String,
    val expiresIn: Int
)
