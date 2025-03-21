package com.example.braintree_payment

import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class BraintreePaymentPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private val VENMO_REQUEST_CODE = 1001

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "braintree_payment")
        channel.setMethodCallHandler(this)
        Log.d("BraintreePaymentPlugin", "onAttachedToEngine called")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("BraintreePaymentPlugin", "onMethodCall called with method: ${call.method}")

        when (call.method) {
            VenmoConstants.VENMO_PAYMENT_METHOD_KEY -> {
                val arguments = call.arguments as? Map<String, Any> ?: emptyMap()
                startVenmoActivity(arguments, result)
            }

            else -> result.notImplemented()
        }
    }

    private fun startVenmoActivity(arguments: Map<String, Any>, result: Result) {
        Log.d("BraintreePaymentPlugin", "activity: ${activity}")

        if (activity == null) {
            result.error(VenmoConstants.VENMO_ERROR_KEY, "Activity is not available", null)
            return
        }

        val intent = Intent(activity!!, VenmoActivity::class.java)
        IntentUtils.putArguments(intent, arguments)
        pendingResult = result
        activity?.startActivityForResult(intent, VENMO_REQUEST_CODE)
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        Log.d(
            "BraintreePaymentPlugin",
            "onActivityResult called with requestCode: $requestCode, resultCode: $resultCode, intent: $intent, extras: ${intent?.extras}"
        )

        if (requestCode == VENMO_REQUEST_CODE) {
            when {
                resultCode == Activity.RESULT_OK && intent != null -> {
                    val nonce = intent.getStringExtra(VenmoConstants.VENMO_NONCE_KEY)
                    pendingResult?.success(nonce)
                }

                resultCode == Activity.RESULT_CANCELED && intent != null -> {
                    val error = intent.getStringExtra(VenmoConstants.VENMO_ERROR_KEY)
                    if (error != null) {
                        pendingResult?.error(VenmoConstants.VENMO_ERROR_KEY, error, null)
                        return
                    }

                    val canceled = intent.getStringExtra(VenmoConstants.VENMO_CANCELED_KEY)
                    if (canceled != null) {
                        pendingResult?.success(null)
                        return
                    }
                }
                else -> {
                    pendingResult?.success(null)
                }
            }
            pendingResult = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            onActivityResult(requestCode, resultCode, data)
            true
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
}
