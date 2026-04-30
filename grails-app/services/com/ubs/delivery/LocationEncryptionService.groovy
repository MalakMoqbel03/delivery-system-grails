package com.ubs.delivery

import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import javax.crypto.spec.GCMParameterSpec
import java.security.SecureRandom


class LocationEncryptionService {

    def encryptionKeyService

    private static final String AES_ALGO = 'AES/GCM/NoPadding'
    private static final int    IV_LEN   = 12
    private static final int    TAG_BITS = 128

    byte[] encryptValue(String plaintext) {
        if (!plaintext) return null
        byte[] key = encryptionKeyService.getEncryptionKey()

        byte[] iv = new byte[IV_LEN]
        new SecureRandom().nextBytes(iv)

        SecretKeySpec keySpec = new SecretKeySpec(key, 'AES')
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, new GCMParameterSpec(TAG_BITS, iv))
        byte[] ciphertext = cipher.doFinal(plaintext.bytes)

        // Prepend IV so decryption can recover it — this was the missing step
        byte[] out = new byte[IV_LEN + ciphertext.length]
        System.arraycopy(iv,         0, out, 0,      IV_LEN)
        System.arraycopy(ciphertext, 0, out, IV_LEN, ciphertext.length)
        return out
    }

    String decryptValue(byte[] stored) {
        if (!stored || stored.length <= IV_LEN) return null
        byte[] key = encryptionKeyService.getEncryptionKey()

        byte[] iv         = Arrays.copyOfRange(stored, 0,      IV_LEN)
        byte[] ciphertext = Arrays.copyOfRange(stored, IV_LEN, stored.length)

        SecretKeySpec keySpec = new SecretKeySpec(key, 'AES')
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.DECRYPT_MODE, keySpec, new GCMParameterSpec(TAG_BITS, iv))
        return new String(cipher.doFinal(ciphertext), 'UTF-8')
    }
}
