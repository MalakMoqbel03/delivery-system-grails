package com.ubs.delivery

import grails.gorm.transactions.Transactional
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec
import java.security.KeyPairGenerator
import java.security.KeyPair
import java.security.PublicKey
import java.security.PrivateKey

@Transactional
class EncryptionService {


    private static KeyPair rsaKeyPair
    private static final String RSA_ALGO = 'RSA/ECB/OAEPWithSHA-256AndMGF1Padding'

    static {
        KeyPairGenerator gen = KeyPairGenerator.getInstance('RSA')
        gen.initialize(2048)
        rsaKeyPair = gen.generateKeyPair()
    }
    private static SecretKey aesKey
    private static final String AES_ALGO = 'AES'

    static {
        KeyGenerator gen = KeyGenerator.getInstance('AES')
        gen.init(256)
        aesKey = gen.generateKey()
    }


    byte[] encryptToken(String plainToken) {
        if (!plainToken) return null
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.ENCRYPT_MODE, aesKey)
        return cipher.doFinal(plainToken.getBytes('UTF-8'))
    }


    String decryptToken(byte[] encryptedToken) {
        if (!encryptedToken) return null
        Cipher cipher = Cipher.getInstance(AES_ALGO)
        cipher.init(Cipher.DECRYPT_MODE, aesKey)
        return new String(cipher.doFinal(encryptedToken), 'UTF-8')
    }


    byte[] encryptCoordinate(Double value) {
        if (value == null) return null
        Cipher cipher = Cipher.getInstance(RSA_ALGO)
        cipher.init(Cipher.ENCRYPT_MODE, rsaKeyPair.public)
        return cipher.doFinal(value.toString().getBytes('UTF-8'))
    }


    Double decryptCoordinate(byte[] encryptedValue) {
        if (!encryptedValue) return null
        Cipher cipher = Cipher.getInstance(RSA_ALGO)
        cipher.init(Cipher.DECRYPT_MODE, rsaKeyPair.private)
        String raw = new String(cipher.doFinal(encryptedValue), 'UTF-8')
        return Double.parseDouble(raw)
    }
}