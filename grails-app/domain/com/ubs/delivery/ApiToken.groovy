package com.ubs.delivery

class ApiToken {

    byte[]  token
    String  clientName
    boolean active    = true
    Date    createdAt = new Date()

    static constraints = {
        token      nullable: false
        clientName nullable: false, blank: false
        active     nullable: false
        createdAt  nullable: false
    }

    static mapping = {
        version  false
        table     'api_token'
        token     sqlType: 'bytea'
        sort      createdAt: 'desc'
    }
}