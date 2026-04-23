package com.ubs.delivery

class ApiRequestLog {

    String method
    String uri
    String clientToken
    int responseStatus
    long durationMs
    Date requestedAt = new Date()

    static constraints = {
        method nullable: false, blank: false
        uri nullable: false, blank: false, maxSize: 1000
        clientToken nullable: true, blank: true, maxSize: 500
        responseStatus nullable: false
        durationMs nullable: false
        requestedAt nullable: false
    }

    static mapping = {
        version  false
        sort requestedAt: 'desc'
    }
}