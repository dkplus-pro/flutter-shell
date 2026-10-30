package com.dk.fluttershell.bridge

import android.util.Log

/// Pure JVM helpers for building [SystemInfo] display strings. Kept free of
/// Android framework calls so they can be unit tested.
object SystemInfoMapper {
    const val UNKNOWN = "unknown"

    fun formatOsVersion(release: String, sdkInt: Int): String =
        "Android ${orUnknown(release)} (API $sdkInt)"

    fun buildNumber(versionCode: Int, longVersionCode: Long, sdkInt: Int): String =
        if (sdkInt >= 28) longVersionCode.toString() else versionCode.toString()

    fun orUnknown(value: String?): String =
        value?.trim()?.takeIf { it.isNotEmpty() } ?: UNKNOWN
}
