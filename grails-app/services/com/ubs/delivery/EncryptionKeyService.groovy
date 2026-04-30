package com.ubs.delivery

import groovy.json.JsonSlurper
import grails.gorm.transactions.Transactional
import grails.util.Holders

@Transactional
class EncryptionKeyService {

    byte[] getEncryptionKey() {
        String vaultAddr = System.getenv('VAULT_ADDR') ?: 'http://127.0.0.1:8200'
        String token     = System.getenv('VAULT_TOKEN')

        // ── Production path: fetch from Vault ────────────────────────────────
        if (token) {
            URL url = new URL("${vaultAddr}/v1/secret/data/delivery-app/encryption-key")
            HttpURLConnection conn = (HttpURLConnection) url.openConnection()
            conn.setRequestMethod('GET')
            conn.setRequestProperty('X-Vault-Token', token)

            if (conn.responseCode != 200) {
                throw new IllegalStateException(
                        "Vault read failed. HTTP ${conn.responseCode}: ${conn.errorStream?.text}"
                )
            }

            def json      = new JsonSlurper().parse(conn.inputStream)
            String hexKey = json.data.data.aes_key
            if (!hexKey) {
                throw new IllegalStateException('aes_key not found in Vault response')
            }
            return hexKey.decodeHex()
        }

        // ── Dev/test fallback 1: env var ENCRYPTION_DEV_KEY ─────────────────
        // Run: export ENCRYPTION_DEV_KEY=<64-hex-chars>  (same key used at seed time)
        String envKey = System.getenv('ENCRYPTION_DEV_KEY')
        if (envKey?.trim()) {
            return envKey.trim().decodeHex()
        }

        // ── Dev/test fallback 2: application.yml encryption.devKey ───────────
        String cfgKey = Holders.config.getProperty('encryption.devKey', String)
        if (cfgKey?.trim()) {
            return cfgKey.trim().decodeHex()
        }

        // ── Nothing configured ────────────────────────────────────────────────
        throw new IllegalStateException(
                "No encryption key available. In development, set one of:\n" +
                        "  1. export VAULT_TOKEN=<token>         (with Vault running)\n" +
                        "  2. export ENCRYPTION_DEV_KEY=<64-hex> (quick local override)\n" +
                        "  3. encryption.devKey in application.yml environments.development\n" +
                        "The key must be the same 32-byte key used when the database was seeded."
        )
    }
}
