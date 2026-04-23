package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.springframework.scheduling.annotation.Scheduled

@Transactional
class DataMinimizationService {

    EncryptionService    encryptionService
    HashingService       hashingService
    MaskingService       maskingService
    GeneralizationService generalizationService
    AuthService          authService

    User minimizeAndSave(Map rawInput) {

        // 1. Extract only what we need — discard the rest immediately
        String  username    = rawInput.username?.trim()?.toLowerCase()
        String  plainPass   = rawInput.plainPassword
        String  rawEmail    = rawInput.email?.trim()?.toLowerCase()
        String  rawPhone    = rawInput.phone
        Date    rawDOB      = rawInput.dateOfBirth
        String  fullAddress = rawInput.fullAddress


        Integer birthYear = rawDOB ? extractYear(rawDOB) : null

        String city = extractCity(fullAddress)

        String phoneHash = hashingService.hashPhone(rawPhone)

        byte[] encryptedEmail = encryptionService.encryptToken(rawEmail)

        String hashedPassword = authService.hashPassword(plainPass)

        String pseudo = UUID.randomUUID().toString()

        //  Build and save the minimized User record
        User user = new User(
                username    : username,
                password    : hashedPassword,
                role        : rawInput.role ?: 'USER',
                email       : encryptedEmail,
                phoneHash   : phoneHash,
                birthYear   : birthYear,
                city        : city,
                pseudoId    : pseudo,
                anonymized  : false
        ).save(flush: true, failOnError: true)

        new PseudonymMapping(
                userId   : user.id,
                pseudoId : pseudo
        ).save(flush: true, failOnError: true)

        return user
    }

    Map<String, Object> getUserView(Long userId, String role) {
        User user = User.get(userId)
        if (!user) return [error: 'User not found']

        switch (role?.toUpperCase()) {

            case 'ADMIN':
                String plainEmail = user.email ?
                        encryptionService.decryptToken(user.email) : null
                return [
                        id         : user.id,
                        pseudoId   : user.pseudoId,
                        username   : user.username,
                        email      : plainEmail,
                        phoneHash  : user.phoneHash,
                        birthYear  : user.birthYear,
                        city       : user.city,
                        role       : user.role,
                        enabled    : user.enabled,
                        anonymized : user.anonymized,
                        createdAt  : user.createdAt,
                        lastLoginAt: user.lastLoginAt
                ]

            case 'SUPPORT':
                return maskingService.buildSupportView(user) + [
                        email: maskingService.maskEmail(
                                user.email ? encryptionService.decryptToken(user.email) : null
                        )
                ]

            case 'ANALYST':
                return generalizationService.buildAnalystView(user)

            default:
                return maskingService.buildSupportView(user)
        }
    }


    @Scheduled(cron = '0 0 2 * * ?')
    void anonymizeInactiveUsers() {
        Date cutoff = twoYearsAgo()

        List<User> inactive = User.withCriteria {
            eq('anonymized', false)
            or {
                isNull('lastLoginAt')
                lt('lastLoginAt', cutoff)
            }
            lt('createdAt', cutoff)
        }

        inactive.each { User u -> wipeUserPii(u)
        }

        log.info("anonymizeInactiveUsers: wiped PII for ${inactive.size()} inactive users")
    }


    @Scheduled(cron = '0 0 3 * * ?')
    void purgeStaleTokens() {
        Date cutoff = oneYearAgo()

        List<ApiToken> stale = ApiToken.withCriteria {
            lt('createdAt', cutoff)
        }

        stale.each { ApiToken t ->
            t.delete(flush: true)
        }

        log.info("purgeStaleTokens: deleted ${stale.size()} stale tokens")
    }


    Map<String, Object> eraseUser(Long userId) {
        User user = User.get(userId)
        if (!user) return [success: false, error: 'User not found']


        int mappingsDeleted = 0
        PseudonymMapping mapping = PseudonymMapping.findByUserId(userId)
        if (mapping) {
            mapping.delete(flush: true)
            mappingsDeleted++
        }
        int tokensDeleted = 0

        wipeUserPii(user)
        user.username = "deleted_${userId}"

        log.info("eraseUser: GDPR erasure completed for userId=${userId}")

        return [
                success         : true,
                userId          : userId,
                mappingsDeleted : mappingsDeleted,
                tokensDeleted   : tokensDeleted,
                userAnonymized  : true
        ]
    }


    private void wipeUserPii(User user) {
        user.email       = null
        user.phoneHash   = null
        user.birthYear   = null
        user.city        = null
        user.pseudoId    = null
        user.anonymized  = true
        user.save(flush: true, failOnError: true)
    }

    private static Integer extractYear(Date dob) {
        Calendar cal = Calendar.getInstance()
        cal.setTime(dob)
        return cal.get(Calendar.YEAR)
    }


    private static String extractCity(String fullAddress) {
        if (!fullAddress?.trim()) return null
        String[] parts = fullAddress.split(',')
        if (parts.length >= 2) {
            return parts[1].trim()
        }
        return fullAddress.trim()
    }

    private static Date twoYearsAgo() {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.YEAR, -2)
        return cal.getTime()
    }

    private static Date oneYearAgo() {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.YEAR, -1)
        return cal.getTime()
    }
}