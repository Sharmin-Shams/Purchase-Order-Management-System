package com.example.codenb.repository

import com.example.codenb.data.AuthService
import com.example.codenb.model.DepartmentDto
import com.example.codenb.model.PurchaseOrderDetails
import com.example.codenb.model.PurchaseOrderSummary
import retrofit2.Response

interface PurchaseOrderRepository{
    suspend fun getDepartments() : Response<List<DepartmentDto>>
    suspend fun searchPurchaseOrders(departmentId: Int) : Response<List<PurchaseOrderSummary>>
    suspend fun getPurchaseOrderDetails(poNumber: Int): Response<PurchaseOrderDetails>
}

class RemotePurchaseOrderRepository(
    private val apiService: AuthService
) : PurchaseOrderRepository {

    override suspend fun getDepartments(): Response<List<DepartmentDto>> {
        return apiService.getDepartments()
    }
    override suspend fun searchPurchaseOrders(departmentId: Int): Response<List<PurchaseOrderSummary>> {
        return apiService.searchPurchaseOrders(departmentId)
    }

    override suspend fun getPurchaseOrderDetails(poNumber: Int): Response<PurchaseOrderDetails> {
        return apiService.getPurchaseOrderDetails(poNumber)
    }
}
