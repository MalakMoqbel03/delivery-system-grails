package com.ubs.delivery


class PseudonymMapping {

    Long   userId
    String pseudoId

    Date   createdAt = new Date()

    static constraints = {
        userId   nullable: false, unique: true
        pseudoId nullable: false, blank: false, unique: true, maxSize: 36
        createdAt nullable: false
    }

    static mapping = {
        version   false
        table     'pseudonym_mapping'
        userId    column: 'user_id'
        pseudoId  column: 'pseudo_id'
        createdAt column: 'created_at'
    }
}