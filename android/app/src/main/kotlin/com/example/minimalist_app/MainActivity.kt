package com.example.minimalist_app

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.minimalist_app/launcher"
    private val APP_SETTINGS_CHANNEL = "app_settings"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Launcher settings channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openHomeLauncherSettings" -> {
                    try {
                        // Open the home screen settings where user can change default launcher
                        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not open home settings: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // App settings channel for uninstall
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "uninstallApp" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            // Use ACTION_DELETE to directly open uninstall dialog
                            val intent = Intent(Intent.ACTION_DELETE)
                            intent.data = Uri.parse("package:$packageName")
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            
                            // Check if the intent can be resolved before starting
                            if (intent.resolveActivity(packageManager) != null) {
                                startActivity(intent)
                                result.success(true)
                            } else {
                                result.error("UNAVAILABLE", "No app found to handle uninstall", null)
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not uninstall app: ${e.message}", null)
                    }
                }
                "openAppSettings" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = Uri.parse("package:$packageName")
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            
                            // Check if the intent can be resolved before starting
                            if (intent.resolveActivity(packageManager) != null) {
                                startActivity(intent)
                                result.success(true)
                            } else {
                                result.error("UNAVAILABLE", "No app found to handle app settings", null)
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not open app settings: ${e.message}", null)
                    }
                }
                "launchGooglePay" -> {
                    try {
                        // Try to launch Google Pay using various intents
                        val packageNames = listOf(
                            "com.google.android.apps.nbu.paisa.user",
                            "com.google.android.apps.pay",
                            "com.google.android.apps.walletnfchost",
                            "com.google.android.gms"  // Google Play Services fallback
                        )
                        
                        var launched = false
                        for (packageName in packageNames) {
                            try {
                                val intent = packageManager.getLaunchIntentForPackage(packageName)
                                if (intent != null) {
                                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    startActivity(intent)
                                    launched = true
                                    break
                                }
                            } catch (e: Exception) {
                                // Try next package name
                            }
                        }
                        
                        if (!launched) {
                            // Fallback: Try opening Google Play Store page for Google Pay
                            try {
                                val intent = Intent(Intent.ACTION_VIEW)
                                intent.data = Uri.parse("https://pay.google.com")
                                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                startActivity(intent)
                                launched = true
                            } catch (e: Exception) {
                                // Fallback failed
                            }
                        }
                        
                        if (launched) {
                            result.success(true)
                        } else {
                            result.error("UNAVAILABLE", "Google Pay app not found and couldn't open web version", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Could not launch Google Pay: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
