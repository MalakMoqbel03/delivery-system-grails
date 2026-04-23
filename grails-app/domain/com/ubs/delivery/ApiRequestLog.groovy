package com.ubs.delivery

class ApiRequestLog {

    String method
    String uri
    String clientToken
    String maskedIp
    int    responseStatus
    long   durationMs
    Date   requestedAt = new Date()

    static constraints = {
        method         nullable: false, blank: false
        uri            nullable: false, blank: false, maxSize: 1000
        clientToken    nullable: true,  blank: true,  maxSize: 100
        maskedIp       nullable: true,  blank: true,  maxSize: 50
        responseStatus nullable: false
        durationMs     nullable: false
        requestedAt    nullable: false
    }

    static mapping = {
        version  false
        table    'api_request_log'
        maskedIp column: 'masked_ip'
        sort requestedAt: 'desc'
    }
}