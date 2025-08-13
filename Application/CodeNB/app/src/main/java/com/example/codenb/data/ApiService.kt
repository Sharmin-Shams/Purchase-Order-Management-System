package com.example.codenb.data

import com.example.codenb.model.DepartmentDto
import com.example.codenb.model.EmployeeDetailsResultDto
import com.example.codenb.model.EmployeeSearchResultDto
import com.example.codenb.model.LoginDto
import com.example.codenb.model.LoginResultDto
import com.example.codenb.model.PurchaseOrderDetails
import com.example.codenb.model.PurchaseOrderSummary
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path
import retrofit2.http.Query
import retrofit2.http.QueryMap

interface AuthService {
    @POST("auth/login")
    suspend fun login(@Body request: LoginDto) : Response<LoginResultDto>

    @GET("Departments")
    suspend fun  getDepartments(): Response<List<DepartmentDto>>

    @GET("PurchaseOrder/search")
    suspend fun  searchPurchaseOrders(@Query("departmentId") departmentId: Int): Response<List<PurchaseOrderSummary>>

    @GET("PurchaseOrder/{poNumber}/details")
    suspend fun getPurchaseOrderDetails(@Path("poNumber") poNumber: Int): Response<PurchaseOrderDetails>

}

interface DepartmentService {
    @GET("departments")
    suspend fun getDepartments(): Response<List<DepartmentDto>>
}

interface EmployeeService {
    @GET("employees/search")
    suspend fun searchEmployees(
        @QueryMap query: Map<String, String>
    ): Response<List<EmployeeSearchResultDto>>;

    @GET("employees/details/{employeeId}")
    suspend fun getEmployee(
        @Path("employeeId") employeeId: String
    ): Response<EmployeeDetailsResultDto>

}