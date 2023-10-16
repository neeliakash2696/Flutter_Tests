package com.indiamart.m
import android.accounts.AccountManager

import android.accounts.Account

import java.util.ArrayList

import java.util.List

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getEmailList") {
                val emailList = getEmailList()
                if (emailList != "") {
                    result.success(emailList)
                } else {
                    result.error("UNAVAILABLE", "Email List not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getEmailList(): Any {
        val emailList = mutableListOf<String>()
        val manager = AccountManager.get(applicationContext)
        val accounts = manager.getAccountsByType("com.google")

        for (account in accounts) {
            emailList.add(account.name)
//            Log.d("AccountName", account.name)
        }

        return emailList
    }
    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }
}

