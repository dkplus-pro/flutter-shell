package com.dk.fluttershell.bridge

import android.util.Log
import com.dk.fluttershell.bridge.generated.PigeonEventSink
import com.dk.fluttershell.bridge.generated.TicksStreamHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/// 1Hz ticker event stream. onListen starts a coroutine on the main thread;
/// onCancel cancels it immediately so no further events are sent.
class TicksStreamHandlerImpl : TicksStreamHandler() {
    private var scope: CoroutineScope? = null

    override fun onListen(p0: Any?, sink: PigeonEventSink<Long>) {
        val newScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        scope = newScope
        var tick = 0L
        newScope.launch {
            while (true) {
                sink.success(tick)
                tick += 1
                delay(1_000)
            }
        }
    }

    override fun onCancel(p0: Any?) {
        scope?.cancel()
        scope = null
        Log.i(TAG, "TICK_STOPPED")
    }

    /// Detach-time cleanup when Flutter unsubscribes without onCancel.
    fun dispose() {
        scope?.cancel()
        scope = null
    }

    companion object {
        const val TAG = "NativeBridge"
    }
}
