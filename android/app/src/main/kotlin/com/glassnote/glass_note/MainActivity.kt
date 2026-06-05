package com.glassnote.glass_note

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingJsonResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "glass_note/json_file_picker",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickJsonFile" -> pickJsonFile(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun pickJsonFile(result: MethodChannel.Result) {
        if (pendingJsonResult != null) {
            result.error("busy", "已有文件选择请求正在进行", null)
            return
        }
        pendingJsonResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("application/json", "text/json", "text/plain", "application/octet-stream"),
            )
        }
        startActivityForResult(intent, JSON_PICK_REQUEST)
    }

    @Deprecated("Deprecated in Android API but still supported by FlutterActivity.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != JSON_PICK_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val result = pendingJsonResult
        pendingJsonResult = null
        if (result == null) {
            return
        }
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }
        val uri: Uri? = data?.data
        if (uri == null) {
            result.error("missing_uri", "无法读取所选文件", null)
            return
        }
        try {
            val text = contentResolver.openInputStream(uri)?.bufferedReader(Charsets.UTF_8)
                ?.use { it.readText() }
            result.success(text)
        } catch (error: Exception) {
            result.error("read_failed", error.message, null)
        }
    }

    private companion object {
        const val JSON_PICK_REQUEST = 9107
    }
}
