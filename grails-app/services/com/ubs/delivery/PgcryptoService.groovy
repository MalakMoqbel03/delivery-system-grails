package com.ubs.delivery

import groovy.sql.Sql
import javax.sql.DataSource
import org.springframework.beans.factory.annotation.Autowired

class PgcryptoService {

    @Autowired
    DataSource dataSource

    String decryptCoordinate(byte[] encryptedBytes) {
        if (!encryptedBytes) return null

        def sql = new Sql(dataSource)
        try {
            String passphrase = System.getenv('DELIVERY_GPG_PASSPHRASE') ?: 'yourPassphrase'
            def row = sql.firstRow("""
                SELECT pgp_pub_decrypt(
                    ?,
                    dearmor(pg_read_file('keys/private.key')),
                    ?
                ) AS value
            """, [encryptedBytes, passphrase])

            return row?.value?.toString()
        } finally {
            sql.close()
        }
    }

    String getClientForTokenId(Long tokenId) {
        if (!tokenId) return null

        def sql = new Sql(dataSource)
        try {
            // 'api_token' is the correct table name (was 'api_token_auth' — does not exist)
            def row = sql.firstRow("""
                SELECT client_name
                FROM api_token
                WHERE id = ?
                  AND active = true
            """, [tokenId])

            return row?.client_name
        } finally {
            sql.close()
        }
    }

    boolean verifyPassword(String username, String plainPassword) {
        if (!username || !plainPassword) return false

        def sql = new Sql(dataSource)
        try {
            def row = sql.firstRow("""
                SELECT COUNT(*) AS match_count
                FROM delivery_user
                WHERE username = ?
                  AND user_password = crypt(?, user_password)
            """, [username, plainPassword])
            // Removed: AND enabled = true  ← column does not exist in delivery_user

            return (row?.match_count ?: 0) > 0
        } finally {
            sql.close()
        }
    }
}