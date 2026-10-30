package com.dk.fluttershell.bridge

import android.app.Activity
import android.util.Log
import com.dk.fluttershell.bridge.generated.ShellFlutterApi
import com.dk.fluttershell.bridge.generated.ShellHostApi
import com.dk.fluttershell.bridge.generated.TicksStreamHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

/// Registers the Pigeon-generated APIs on the engine and forwards native
/// screen results back to Dart. Also owns the Activity reference through
/// [ActivityAware]; no static Activity references are kept.
class NativeBridgePlugin :
    FlutterPlugin,
    ActivityAware {
    private var activity: Activity? = null
    private var hostApi: ShellHostApiImpl? = null
    private var ticksHandler: TicksStreamHandlerImpl? = null
    private var ticksChannel: com.dk.fluttershell.bridge.generated.TicksEventChannel? = null
    private var resultDispatcher: NativeResultDispatcher? = null
    private var dispatcherScope: CoroutineScope? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        hostApi = ShellHostApiImpl(
            contextProvider = { context },
            activityProvider = { activity },
        )
        ShellHostApi.setUp(binding.binaryMessenger, hostApi)

        ticksHandler = TicksStreamHandlerImpl()
        ticksChannel = TicksStreamHandler.register(binding.binaryMessenger, ticksHandler!!)

        dispatcherScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        resultDispatcher = NativeResultDispatcher(
            flutterApi = ShellFlutterApi(binding.binaryMessenger),
            scope = dispatcherScope!!,
        )
        NativeResultBus.install(resultDispatcher!!)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ShellHostApi.setUp(binding.binaryMessenger, null)
        ticksChannel?.setStreamHandler(null)
        ticksChannel = null
        ticksHandler?.dispose()
        ticksHandler = null
        resultDispatcher?.cancel()
        resultDispatcher = null
        dispatcherScope?.cancel()
        dispatcherScope = null
        NativeResultBus.uninstall()
        hostApi = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
