package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

@Transactional
class AuthService {

    private BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(10)
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
}
