package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.springframework.beans.factory.annotation.Value

import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.security.SecureRandom

@Transactional
class EncryptionService {

    @Value('${app.encryptionKey}')
    String encryptionKeyHex

    private static final String AES_ALGO = 'AES/GCM/NoPadding'
    private static final int    IV_LEN   = 12
    private static final int    TAG_BITS = 128

    private SecretKey getKey() {
        if (!encryptionKeyHex?.trim()) {
            throw new IllegalStateException(
                    'APP_ENCRYPTION_KEY env var is not set. ' +
                            'Run EncryptionService.generateKeyHex() to generate one.')
        }
        byte[] keyBytes = hexToBytes(encryptionKeyHex.trim())
        if (keyBytes.length != 32) {
            throw new IllegalStateException(
                    "APP_ENCRYPTION_KEY must be 64 hex chars (32 bytes). Got ${keyBytes.length}.")
        }
        return new SecretKeySpec(keyBytes, 'AES')
    }

    byte[] encryptCoordinate(Double value) {
        if (value == null) return null
        return encrypt(value.toString().getBytes('UTF-8'))
    }

    Double decryptCoordinate(byte[] encryptedValue) {
        if (!encryptedValue) return null
        return Double.parseDouble(new String(decrypt(encryptedValue), 'UTF-8'))
    }


    Map decryptCoords(Location location) {
        if (!location) return [x: null, y: null]
        Double x = decryptCoordinate(location.x)
        Double y = decryptCoordinate(location.y)
        return [x: x, y: y]
    }
    byte[] encryptToken(String plainToken) {
        if (!plainToken) return null
        return encrypt(plainToken.getBytes('UTF-8'))
    }

    String decryptToken(byte[] encryptedToken) {
        if (!encryptedToken) return null
        return new String(decrypt(encryptedToken), 'UTF-8')
    }
    private byte[] encrypt(byte[] plainBytes) {
        byte[] iv = new byte[IV_LEN]
        new SecureRandom().nextBytes(iv)
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.ENCRYPT_MODE, getKey(), new GCMParameterSpec(TAG_BITS, iv))
        byte[] ciphertext = cipher.doFinal(plainBytes)
        byte[] out = new byte[IV_LEN + ciphertext.length]
        System.arraycopy(iv,         0, out, 0,      IV_LEN)
        System.arraycopy(ciphertext, 0, out, IV_LEN, ciphertext.length)
        return out
    }

    private byte[] decrypt(byte[] stored) {
        if (stored.length <= IV_LEN) {
            throw new IllegalArgumentException("Stored bytes too short (${stored.length}).")
        }
        byte[] iv         = Arrays.copyOfRange(stored, 0,      IV_LEN)
        byte[] ciphertext = Arrays.copyOfRange(stored, IV_LEN, stored.length)
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.DECRYPT_MODE, getKey(), new GCMParameterSpec(TAG_BITS, iv))
        return cipher.doFinal(ciphertext)
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length()
        byte[] data = new byte[len.intdiv(2)]
        for (int i = 0; i < len; i += 2) {
            data[i.intdiv(2)] = (byte)((Character.digit(hex.charAt(i), 16) << 4)
                    +  Character.digit(hex.charAt(i+1),   16))
        }
        return data
    }

    static String generateKeyHex() {
        byte[] key = new byte[32]
        new SecureRandom().nextBytes(key)
        return key.collect { String.format('%02x', it & 0xff) }.join('')
    }
}