package com.example.codenb.model

import kotlinx.serialization.Serializable


@Serializable
data class PurchaseOrderDetails(

    val purchaseOrderNumber : String,
    val supervisorFullName : String,
    val purchaseStatus : String,
    val items: List<PurchaseOrderItem> = emptyList(),
    val grandTotal : Double
)
