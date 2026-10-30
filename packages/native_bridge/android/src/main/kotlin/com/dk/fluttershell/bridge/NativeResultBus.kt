package com.dk.fluttershell.bridge

import android.util.Log
import com.dk.fluttershell.bridge.generated.NativeScreenResult

/// Registry for the dispatcher that forwards native screen results to Dart.
///
/// Process-level singleton by design: v0 supports a single Flutter engine
/// (docs/01 §19). When the plugin is detached the dispatcher is uninstalled
/// and results are dropped with a log marker instead of crashing.
object NativeResultBus {
    @Volatile
    private var dispatcher: NativeResultDispatcher? = null

    fun install(newDispatcher: NativeResultDispatcher) {
        dispatcher = newDispatcher
    }

    fun uninstall() {
        dispatcher = null
    }

    fun send(result: NativeScreenResult) {
        val current = dispatcher
        if (current == null) {
            Log.i(TAG, "RESULT_DROPPED no dispatcher; confirmed=${result.confirmed}")
            return
        }
        Log.i(TAG, "RESULT confirmed=${result.confirmed} message=${result.message}")
        current.dispatch(result)
    }

    const val TAG = "NativeBridge"
}
