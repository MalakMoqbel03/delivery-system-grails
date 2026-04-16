package com.ubs.delivery

class RequestMap {

    String url
    String configAttribute

    static constraints = {
        url             blank: false, unique: true
        configAttribute blank: false
    }

    static mapping = {
        cache true
    }

    @Override
    String toString() {
        "${url} → ${configAttribute}"
    }
}