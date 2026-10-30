package com.dk.fluttershell.bridge

import kotlin.test.Test
import kotlin.test.assertEquals

class SystemInfoMapperTest {
    @Test
    fun formatsOsVersion() {
        assertEquals("Android 16 (API 36)", SystemInfoMapper.formatOsVersion("16", 36))
    }

    @Test
    fun usesLongVersionCodeFromApi28() {
        assertEquals("42", SystemInfoMapper.buildNumber(7, 42L, 28))
        assertEquals("7", SystemInfoMapper.buildNumber(7, 42L, 27))
    }

    @Test
    fun fallsBackForBlankValues() {
        assertEquals("unknown", SystemInfoMapper.orUnknown("  "))
    }
}
