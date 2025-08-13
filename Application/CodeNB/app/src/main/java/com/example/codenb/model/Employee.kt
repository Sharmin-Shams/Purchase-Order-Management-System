package com.example.codenb.model

import kotlinx.serialization.Serializable

@Serializable
data class EmployeeSearchDto(
    val departmentID: Int?,
    val employeeID: String?,
    val lastName: String?,
)

@Serializable
data class EmployeeSearchResultDto(
    val id: Int,
    val firstName: String,
    val lastName: String,
    val workPhone: String,
    val officeLocation: String,
    val position: String
)

@Serializable
data class EmployeeDetailsResultDto(
    val id: Int,
    val firstName: String,
    val middleInitial: String?,
    val lastName: String,
    val mailingAddress: String,
    val workPhone: String,
    val cellPhone: String,
    val email: String
)