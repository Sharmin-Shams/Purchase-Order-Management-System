package com.example.codenb.model

import kotlinx.serialization.Serializable

@Serializable
data class PurchaseOrderSummary(
    val  purchaseOrderNumber : String,
    val creationDate : String,
    val supervisorName :String,
    val purchaseOrderStatus: String

)
