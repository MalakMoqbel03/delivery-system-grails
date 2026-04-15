package com.ubs.delivery

class ApiToken {
    String token
    String clientName
    boolean active = true
    Date createdAt = new Date()

    static constraints = {
        token nullable: false, blank: false, unique: true
        clientName nullable: false, blank: false
        active nullable: false
        createdAt nullable: false
    }

    static mapping = {
        sort createdAt: 'desc'
    }
}