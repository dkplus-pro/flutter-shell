package com.dk.fluttershell.bridge

import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.dk.fluttershell.bridge.generated.FlutterError
import com.dk.fluttershell.bridge.generated.ShellHostApi
import com.dk.fluttershell.bridge.generated.SystemInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/// Provides a foreground [Activity] or null; owned by [NativeBridgePlugin].
fun interface ActivityProvider {
    fun activity(): Activity?
}

/// Implements the generated [ShellHostApi].
///
/// Threading per docs/02 §5: PackageManager reads go to Dispatchers.IO;
/// `startActivity` stays on the (main) caller thread.
class ShellHostApiImpl(
    private val contextProvider: () -> Context,
    private val activityProvider: ActivityProvider,
) : ShellHostApi {
    override suspend fun getSystemInfo(): SystemInfo = withContext(Dispatchers.IO) {
        try {
            val context = contextProvider()
            val packageInfo: PackageInfo? =
                context.packageManager.getPackageInfo(context.packageName, 0)
            val versionCode = packageInfo?.versionCode ?: 0
            val longVersionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo?.longVersionCode ?: versionCode.toLong()
            } else {
                versionCode.toLong()
            }
            SystemInfo(
                platform = "android",
                osVersion = SystemInfoMapper.formatOsVersion(
                    Build.VERSION.RELEASE,
                    Build.VERSION.SDK_INT,
                ),
                deviceModel = SystemInfoMapper.orUnknown(Build.MODEL),
                manufacturer = SystemInfoMapper.orUnknown(Build.MANUFACTURER),
                appVersion = SystemInfoMapper.orUnknown(packageInfo?.versionName),
                buildNumber = SystemInfoMapper.buildNumber(
                    versionCode,
                    longVersionCode,
                    Build.VERSION.SDK_INT,
                ),
            )
        } catch (e: Exception) {
            Log.w(TAG, "SYSTEM_INFO_FAILED ${e.message}")
            throw FlutterError(CODE_SYSTEM_INFO_FAILED, "Failed to read system info: ${e.message}", null)
        }
    }

    override suspend fun openNativeScreen(title: String, message: String): Boolean {
        val activity = activityProvider.activity()
            ?: throw FlutterError(CODE_NO_ACTIVITY, "No foreground activity", null)
        return try {
            activity.startActivity(NativeInfoActivity.createIntent(activity, title, message))
            Log.i(TAG, "SCREEN_OPENED title=$title")
            true
        } catch (e: Exception) {
            Log.w(TAG, "NATIVE_SCREEN_LAUNCH_FAILED ${e.message}")
            throw FlutterError(
                CODE_NATIVE_SCREEN_LAUNCH_FAILED,
                "Failed to launch native screen: ${e.message}",
                null,
            )
        }
    }

    companion object {
        const val TAG = "NativeBridge"
        const val CODE_NO_ACTIVITY = "NO_ACTIVITY"
        const val CODE_SYSTEM_INFO_FAILED = "SYSTEM_INFO_FAILED"
        const val CODE_NATIVE_SCREEN_LAUNCH_FAILED = "NATIVE_SCREEN_LAUNCH_FAILED"
    }
}
