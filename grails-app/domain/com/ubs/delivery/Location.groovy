package com.ubs.delivery

class Location {

    String name
    String code
    Double x
    Double y

    static constraints = {
        name nullable: false, blank: false
        code nullable: false, blank: false, unique: true
        x    nullable: false
        y    nullable: false
    }

    @Override
    String toString() {
        return "${name} (${code})"
    }
}