package com.example.codenb.data

import android.content.Context
import com.example.codenb.network.AuthInterceptor
import com.example.codenb.repository.AuthRepository
import com.example.codenb.repository.DepartmentRepository
import com.example.codenb.repository.EmployeeRepository
import com.example.codenb.repository.PurchaseOrderRepository
import com.example.codenb.repository.RemoteAuthRepository
import com.example.codenb.repository.RemoteDepartmentRepository
import com.example.codenb.repository.RemoteEmployeeRepository
import com.example.codenb.repository.RemotePurchaseOrderRepository
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import retrofit2.Retrofit

interface AppContainer {
    val tokenManager: TokenManager
    val authRepository: AuthRepository
    val deptRepository: DepartmentRepository
    val empRepository: EmployeeRepository
    val purchaseOrderRepository: PurchaseOrderRepository
}

class DefaultAppContainer(
    private val appContext: Context
) : AppContainer {
    private val baseUrl = "http://10.0.2.2:5130/api/"

    override val tokenManager: TokenManager by lazy {
        TokenManager(appContext)
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(AuthInterceptor(tokenManager))
        .build()

    private val json = Json {
        ignoreUnknownKeys = true
    }

    private val retrofit = Retrofit.Builder()
        .baseUrl(baseUrl)
        .client(client)
        .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
        .build()


    ///REGISTER REPO AND SERVICE INTERFACES AND CLASSES
    private val authService: AuthService by lazy {
        retrofit.create(AuthService::class.java)
    }

    override val authRepository: AuthRepository by lazy {
        RemoteAuthRepository(authService)
    }

    private val departmentService: DepartmentService by lazy {
        retrofit.create(DepartmentService::class.java)
    }

    override val deptRepository: DepartmentRepository by lazy {
        RemoteDepartmentRepository(departmentService)
    }

    private val employeeService: EmployeeService by lazy {
        retrofit.create(EmployeeService::class.java)
    }

    override val empRepository: EmployeeRepository by lazy {
        RemoteEmployeeRepository(employeeService)
    }

    override val purchaseOrderRepository: PurchaseOrderRepository by lazy {
        RemotePurchaseOrderRepository(authService)
    }
}