package com.example.codenb.repository

import com.example.codenb.data.DepartmentService
import com.example.codenb.model.DepartmentDto
import retrofit2.Response

interface DepartmentRepository {
    suspend fun getDepartments(): Response<List<DepartmentDto>>
}

class RemoteDepartmentRepository(
    private val deptService: DepartmentService
) : DepartmentRepository {
    override suspend fun getDepartments(): Response<List<DepartmentDto>> {
        return deptService.getDepartments()
    }
}