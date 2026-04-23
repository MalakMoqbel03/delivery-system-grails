package com.ubs.delivery

import grails.gorm.transactions.Transactional


@Transactional(readOnly = true)
class MaskingService {

    String maskEmail(String email) {
        if (!email?.trim()) return '***'
        int atIdx = email.indexOf('@')
        if (atIdx < 0) return '***'

        String local  = email.substring(0, atIdx)
        String domain = email.substring(atIdx + 1)

        String maskedLocal = maskMiddle(local, 1, 0)

        int dotIdx = domain.lastIndexOf('.')
        String maskedDomain
        if (dotIdx > 0) {
            String domainBody = domain.substring(0, dotIdx)
            String tld        = domain.substring(dotIdx)
            maskedDomain = maskMiddle(domainBody, 1, 0) + tld
        } else {
            maskedDomain = maskMiddle(domain, 1, 0)
        }

        return "${maskedLocal}@${maskedDomain}"
    }

    String maskUsername(String username) {
        if (!username?.trim()) return '***'
        return maskMiddle(username.trim(), 1, 1)
    }


    String maskPhoneHash(String phoneHash) {
        if (!phoneHash) return 'not provided'
        return '●●●●-●●●●'
    }


    Map<String, Object> buildSupportView(User user) {
        [
                id           : user.id,
                username     : maskUsername(user.username),
                // email intentionally excluded — caller must decrypt first then mask
                phone        : maskPhoneHash(user.phoneHash),
                city         : user.city ?: 'Unknown',
                role         : user.role,
                enabled      : user.enabled
        ]
    }


    private static String maskMiddle(String s, int keepStart, int keepEnd) {
        if (!s) return ''
        int len = s.length()
        int keep = keepStart + keepEnd
        if (len <= keep) return s   // too short to mask meaningfully
        String start = s.substring(0, keepStart)
        String end   = keepEnd > 0 ? s.substring(len - keepEnd) : ''
        String stars = '*' * (len - keep)
        return start + stars + end
    }
}