package com.dk.fluttershell.bridge

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.dk.fluttershell.bridge.generated.NativeScreenResult

/// Minimal Compose demo screen proving the host + round-trip path. Reads
/// title/message from intent extras and reports exactly one result back via
/// [NativeResultBus] (confirm, cancel or back press).
class NativeInfoActivity : ComponentActivity() {
    private var dispatched = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val title = intent.getStringExtra(EXTRA_TITLE).orEmpty()
        val message = intent.getStringExtra(EXTRA_MESSAGE).orEmpty()
        setContent {
            MaterialTheme {
                val nativeConfirm = stringResource(R.string.native_confirm)
                val nativeCancel = stringResource(R.string.native_cancel)
                Scaffold(modifier = Modifier.fillMaxSize()) { padding ->
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding)
                            .padding(screenPadding),
                        verticalArrangement = Arrangement.spacedBy(itemSpacing),
                    ) {
                        Text(title, style = MaterialTheme.typography.headlineSmall)
                        Text(message, style = MaterialTheme.typography.bodyLarge)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(itemSpacing),
                        ) {
                            Button(onClick = { finishWithResult(confirmed = true) }) {
                                Text(nativeConfirm)
                            }
                            Button(onClick = { finishWithResult(confirmed = false) }) {
                                Text(nativeCancel)
                            }
                        }
                    }
                }
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        finishWithResult(confirmed = false)
    }

    private fun finishWithResult(confirmed: Boolean) {
        if (dispatched) {
            return
        }
        dispatched = true
        val message = if (confirmed) MESSAGE_CONFIRMED else MESSAGE_CANCELLED
        NativeResultBus.send(NativeScreenResult(confirmed, message))
        finish()
    }

    companion object {
        const val TAG = "NativeBridge"
        const val EXTRA_TITLE = "com.dk.fluttershell.bridge.extra.TITLE"
        const val EXTRA_MESSAGE = "com.dk.fluttershell.bridge.extra.MESSAGE"
        const val MESSAGE_CONFIRMED = "Confirmed in native screen"
        const val MESSAGE_CANCELLED = "Cancelled in native screen"

        private val screenPadding = 16.dp
        private val itemSpacing = 8.dp

        fun createIntent(context: Context, title: String, message: String): Intent =
            Intent(context, NativeInfoActivity::class.java).apply {
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_MESSAGE, message)
            }
    }
}
