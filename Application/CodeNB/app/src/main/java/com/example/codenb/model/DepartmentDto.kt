package com.example.codenb.model

import kotlinx.serialization.Serializable

@Serializable
data class DepartmentDto(
    val id: Int,
    val name: String
)
