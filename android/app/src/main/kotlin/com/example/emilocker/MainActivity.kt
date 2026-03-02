package com.example.emilocker

import android.app.Activity
import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.view.WindowManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * MainActivity with MethodChannel for device control operations
 * Supports Kiosk Mode, Device Locking, Screenshot Prevention, and Root Detection
 */
class MainActivity : FlutterActivity() {
    private val DEVICE_CONTROL_CHANNEL = "com.emilocker.device_control"
    private val SECURITY_CHANNEL = "com.emilocker.security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Device Control Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableKioskMode" -> {
                    try {
                        enableKioskMode()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", e.message, null)
                    }
                }
                "disableKioskMode" -> {
                    try {
                        disableKioskMode()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", e.message, null)
                    }
                }
                "lockDevice" -> {
                    try {
                        lockDevice()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LOCK_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Security Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "preventScreenshot" -> {
                    try {
                        preventScreenshot()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCREENSHOT_ERROR", e.message, null)
                    }
                }
                "allowScreenshot" -> {
                    try {
                        allowScreenshot()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCREENSHOT_ERROR", e.message, null)
                    }
                }
                "checkRootAccess" -> {
                    try {
                        val isRooted = checkRootAccess()
                        result.success(isRooted)
                    } catch (e: Exception) {
                        result.error("ROOT_CHECK_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Enable Kiosk Mode using lockTask()
     * Note: Requires Device Owner mode or being set as a lock task app
     */
    private fun enableKioskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                setLockTaskMode(true)
                startLockTask()
            } catch (e: SecurityException) {
                // If not device owner, try alternative approach
                // This requires the app to be set as a lock task app in device settings
                throw SecurityException("Kiosk mode requires Device Owner privileges or Lock Task configuration")
            }
        }
    }

    /**
     * Disable Kiosk Mode
     */
    private fun disableKioskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                stopLockTask()
                setLockTaskMode(false)
            } catch (e: Exception) {
                // Ignore if not in lock task mode
            }
        }
    }

    /**
     * Lock the device
     * Note: Requires Device Admin privileges
     */
    private fun lockDevice() {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponent = ComponentName(this, DeviceAdminReceiver::class.java)
        
        if (devicePolicyManager.isAdminActive(adminComponent)) {
            devicePolicyManager.lockNow()
        } else {
            throw SecurityException("Device Admin privileges required")
        }
    }

    /**
     * Prevent screenshots by setting FLAG_SECURE
     */
    private fun preventScreenshot() {
        runOnUiThread {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
    }

    /**
     * Allow screenshots by clearing FLAG_SECURE
     */
    private fun allowScreenshot() {
        runOnUiThread {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    /**
     * Check if device is rooted
     * Checks for common root indicators
     */
    private fun checkRootAccess(): Boolean {
        val rootIndicators = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )

        // Check for su binary
        for (path in rootIndicators) {
            if (File(path).exists()) {
                return true
            }
        }

        // Check for test-keys (indicates custom ROM)
        try {
            val buildTags = Build.TAGS
            if (buildTags != null && buildTags.contains("test-keys")) {
                return true
            }
        } catch (e: Exception) {
            // Ignore
        }

        return false
    }

    /**
     * Set lock task mode
     */
    private fun setLockTaskMode(enabled: Boolean) {
        // This is handled by the system when startLockTask() is called
        // For Device Owner mode, this is automatically enabled
    }
}

/**
 * Device Admin Receiver for device locking functionality
 * Register this in AndroidManifest.xml
 */
class DeviceAdminReceiver : android.app.admin.DeviceAdminReceiver() {
    // Implementation handled by Android framework
}
