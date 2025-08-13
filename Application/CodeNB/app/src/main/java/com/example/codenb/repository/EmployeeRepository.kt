package com.example.codenb.repository

import com.example.codenb.data.EmployeeService
import com.example.codenb.model.EmployeeDetailsResultDto
import com.example.codenb.model.EmployeeSearchDto
import com.example.codenb.model.EmployeeSearchResultDto
import retrofit2.Response


interface EmployeeRepository {
    suspend fun searchEmployees(query: EmployeeSearchDto): Response<List<EmployeeSearchResultDto>>
    suspend fun getEmployee(employeeId: String): Response<EmployeeDetailsResultDto>
}

class RemoteEmployeeRepository(
    private val empService: EmployeeService
) : EmployeeRepository {
    override suspend fun searchEmployees(query: EmployeeSearchDto):
            Response<List<EmployeeSearchResultDto>> {
        val queryMap = query.toQueryMap()
        return empService.searchEmployees(queryMap)
    }

    override suspend fun getEmployee(employeeId: String): Response<EmployeeDetailsResultDto> {
        return empService.getEmployee(employeeId)
    }

    private fun EmployeeSearchDto.toQueryMap(): Map<String, String> {
        return buildMap {
            departmentID?.takeIf { it != 0 }?.let { put("departmentID", it.toString()) }
            employeeID?.takeIf { it.isNotBlank() }?.let { put("employeeID", it) }
            lastName?.takeIf { it.isNotBlank() }?.let { put("lastName", it) }
        }
    }
}