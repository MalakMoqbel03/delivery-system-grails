package com.ubs.delivery


class AIQueryLog {

    String locationCode
    String locationName
    String queryType
    String aiResponse
    Date   queriedAt = new Date()

    static constraints = {
        locationCode nullable: false
        locationName nullable: false
        queryType    nullable: false
        aiResponse   nullable: false, maxSize: 2000
        queriedAt    nullable: false
    }

    static mapping = {
        sort queriedAt: 'desc'
    }
}