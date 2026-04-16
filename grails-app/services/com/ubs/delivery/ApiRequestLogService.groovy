package com.ubs.delivery

import grails.gorm.transactions.Transactional


@Transactional
class ApiRequestLogService {

    void save(String method, String uri, String clientToken,
              int responseStatus, long durationMs) {
        new ApiRequestLog(
                method        : method,
                uri           : uri,
                clientToken   : clientToken,
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
}