package com.example.codenb.data

import android.content.Context
import android.content.SharedPreferences
import com.example.codenb.model.LoginResultDto
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class TokenManager(context: Context) {
    private val prefKey = "auth_data"
    private val prefs: SharedPreferences =
        context.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)

    private val json = Json { ignoreUnknownKeys = true }

    fun saveAuth(auth: LoginResultDto) {
        val jsonString = json.encodeToString(auth)
        prefs.edit().putString(prefKey, jsonString).apply()
    }

    private fun getAuth(): LoginResultDto? {
        val jsonString = prefs.getString(prefKey, null)
        return jsonString?.let {
            try {
                json.decodeFromString<LoginResultDto>(it)
            } catch (e: Exception) {
                null
            }
        }
    }

    fun getRole(): String? = getAuth()?.role

    fun getName(): String? {
        return getAuth()?.let { it.firstName + " " + it.lastName }
    }

    fun getToken(): String? = getAuth()?.token

    fun clearToken() {
        prefs.edit().remove(prefKey).apply()
    }
}