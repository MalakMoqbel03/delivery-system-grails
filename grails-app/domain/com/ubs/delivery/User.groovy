package com.ubs.delivery


class User {
    String username
    String password
    String role
    boolean enabled = true
    static constraints = {
        username nullable: false, blank: false, unique: true, size: 3..50
        password nullable: false, blank: false
        role     nullable: false, blank: false, inList: ['ADMIN', 'USER']
    }

    static mapping = {
        password column: 'user_password'
    }
}
