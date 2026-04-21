package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

@Transactional
class AuthService {

    EncryptionService encryptionService

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(10)

    String hashPassword(String plainText) {
        return encoder.encode(plainText)
    }

    @Transactional(readOnly = true)
    User authenticate(String username, String plainPassword) {
        if (!username || !plainPassword) return null
        User user = User.findByUsernameAndEnabled(username.trim().toLowerCase(), true)
        if (!user) return null
        if (encoder.matches(plainPassword, user.password)) {
            return user
        }
        return null
    }

    ApiToken saveToken(String plainToken, String clientName) {
        byte[] encrypted = encryptionService.encryptToken(plainToken)
        new ApiToken(
                token     : encrypted,
                clientName: clientName,
                active    : true,
                createdAt : new Date()
        ).save(failOnError: true, flush: true)
    }

    @Transactional(readOnly = true)
    ApiToken findActiveToken(String plainToken) {
        if (!plainToken) return null
        List<ApiToken> activeTokens = ApiToken.findAllByActive(true)
        return activeTokens.find { apiToken ->
            try {
                String decrypted = encryptionService.decryptToken(apiToken.token)
                return decrypted == plainToken
            } catch (Exception e) {
                return false
            }
        }
    }
}