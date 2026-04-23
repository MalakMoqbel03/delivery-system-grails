package com.ubs.delivery

class Location {

    String name
    String code
    byte[] x
    byte[] y

    static constraints = {
        name nullable: false, blank: false
        code nullable: false, blank: false, unique: true
        x    nullable: false
        y    nullable: false
    }
    static mapping = {
        table 'location'
        tablePerSubclass true
        x sqlType: 'bytea'
        y sqlType: 'bytea'
    }

    @Override
    String toString() {
        return "${name} (${code})"
    }
}