package com.example.codenb.model

import kotlinx.serialization.Serializable

@Serializable
data class PurchaseOrderItem(
    val itemName: String,
    val itemQuantity: Int,
    val itemPrice: Double,
    val itemStatus: String,

)
