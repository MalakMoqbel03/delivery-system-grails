package com.ubs.delivery

class AIQueryLog {

    String locationCode

    String queryType
    String aiResponse
    Date   aggregatedAt

    static constraints = {
        locationCode  nullable: false, blank: false, maxSize: 50
        queryType     nullable: false, blank: false, maxSize: 50
        aiResponse    nullable: false, maxSize: 200
        aggregatedAt  nullable: false
    }

    static mapping = {
        version      false
        table        'ai_query_log'
        aggregatedAt column: 'aggregated_at'
        sort         aggregatedAt: 'desc'
    }
}