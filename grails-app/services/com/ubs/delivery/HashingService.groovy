package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.springframework.beans.factory.annotation.Value

import java.security.MessageDigest

/**
 * HashingService — one-way HMAC-SHA-256 hashing for phone numbers.
 *
 * WHY ONE-WAY HASHING FOR PHONE?
 * ─────────────────────────────────────────────────────────────────
 * Phone numbers are a good candidate for one-way hashing (not encryption)
 * because:
 *   - You almost never need to display the original phone to a user or admin.
 *   - You DO sometimes need to check "does this phone number already exist?"
 *     (deduplication, fraud checks) — and a hash lets you do that without
 *     storing the raw number.
 *   - If the DB is breached, a plain SHA-256 of a phone can be brute-forced
 *     easily (phones are low-entropy, ~10^10 possibilities). A keyed HMAC
 *     with a secret pepper makes rainbow tables useless.
 *
 * HOW IT WORKS:
 *   phone → normalize (strip spaces/dashes) → HMAC-SHA-256(phone, pepper)
 *   → hex string stored in DB
 *
 * The pepper is loaded from the same env-var block as the encryption key.
 * Never store the pepper in the DB itself.
 */
@Transactional
class HashingService {

    @Value('${app.hashingPepper}')
    String hashingPepper

    String hashPhone(String rawPhone) {
        if (!rawPhone?.trim()) return null
        String normalized = rawPhone.trim().replaceAll(/[\s\-\(\)\.]/, '')
        return hmacSha256(normalized, hashingPepper)
    }

    boolean phoneMatches(String rawPhone, String storedHash) {
        if (!rawPhone || !storedHash) return false
        return hashPhone(rawPhone) == storedHash
    }

    private static String hmacSha256(String data, String key) {
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance('HmacSHA256')
        javax.crypto.spec.SecretKeySpec secretKey =
                new javax.crypto.spec.SecretKeySpec(key.getBytes('UTF-8'), 'HmacSHA256')
        mac.init(secretKey)
        byte[] rawHmac = mac.doFinal(data.getBytes('UTF-8'))
        return rawHmac.collect { String.format('%02x', it & 0xff) }.join('')
    }
}