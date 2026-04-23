package com.ubs.delivery

import grails.gorm.transactions.Transactional

@Transactional
class ApiRequestLogService {

    void save(String method, String rawUri, String rawToken,
              String rawIp, int responseStatus, long durationMs) {
        new ApiRequestLog(
                method        : method,
                uri           : sanitizeUri(rawUri),
                clientToken   : truncateToken(rawToken),
                maskedIp      : maskIp(rawIp),
                responseStatus: responseStatus,
                durationMs    : durationMs,
                requestedAt   : new Date()
        ).save(failOnError: false, flush: true)
    }

    List<ApiRequestLog> listLogs(int max = 50, String uriFilter = null,
                                 Integer statusFilter = null) {
        ApiRequestLog.where {
            if (uriFilter)    { uri == uriFilter }
            if (statusFilter) { responseStatus == statusFilter }
        }.list(max: max, sort: 'requestedAt', order: 'desc')
    }

    String maskIp(String rawIp) {
        if (!rawIp?.trim()) return 'unknown'
        String ip = rawIp.trim()

        if (ip.contains('.')) {

            int lastDot = ip.lastIndexOf('.')
            return ip.substring(0, lastDot) + '.xxx'
        } else if (ip.contains(':')) {

            int lastColon = ip.lastIndexOf(':')
            return ip.substring(0, lastColon) + ':xxx'
        }
        return 'unknown'
    }

    String sanitizeUri(String rawUri) {
        if (!rawUri?.trim()) return '/'
        int qIdx = rawUri.indexOf('?')
        return qIdx >= 0 ? rawUri.substring(0, qIdx) : rawUri
    }


    String truncateToken(String rawToken) {
        if (!rawToken?.trim()) return null
        // Strip "Bearer " prefix if present
        String token = rawToken.trim()
        if (token.startsWith('Bearer ')) {
            token = token.substring(7).trim()
        }
        if (token.length() <= 6) return token
        return token.substring(0, 6) + '[truncated]'
    }
}