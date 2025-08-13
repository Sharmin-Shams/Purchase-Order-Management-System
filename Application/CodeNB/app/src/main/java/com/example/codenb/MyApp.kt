package com.example.codenb

import android.app.Application
import com.example.codenb.data.AppContainer
import com.example.codenb.data.DefaultAppContainer

class MyApp : Application() {
    lateinit var container: AppContainer
    override fun onCreate() {
        super.onCreate()
        container = DefaultAppContainer(applicationContext)
    }
}