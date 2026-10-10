package com.wassaly.wassaly

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    // Canal "importance haute" : la notification s'affiche en banniere avec son
    // et vibration, meme quand l'application est fermee. Son identifiant doit
    // rester identique a celui de AndroidManifest.xml et de functions/index.js.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "wassaly_high",
            "Wassaly",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Messages et nouvelles demandes"
        }
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }
}
