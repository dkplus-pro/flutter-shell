package com.dk.fluttershell.bridge

import android.util.Log
import com.dk.fluttershell.bridge.generated.NativeScreenResult
import com.dk.fluttershell.bridge.generated.ShellFlutterApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.launch

/// Forwards [NativeScreenResult]s from the native demo screen to Dart through
/// the generated [ShellFlutterApi] proxy on the main thread. Failures are
/// logged only; a dropped result must never crash the app.
class NativeResultDispatcher(
    private val flutterApi: ShellFlutterApi,
    private val scope: CoroutineScope,
) {
    fun dispatch(result: NativeScreenResult) {
        scope.launch {
            try {
                flutterApi.onNativeScreenResult(result)
            } catch (e: Exception) {
                Log.w(TAG, "RESULT_DROPPED ${e.message}")
            }
        }
    }

    fun cancel() {
        scope.coroutineContext.cancelChildren()
    }

    companion object {
        const val TAG = "NativeBridge"
    }
}
