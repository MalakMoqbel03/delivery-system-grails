package com.ubs.delivery

import grails.converters.JSON
import java.time.Instant

class ApiHealthController {

    static allowedMethods = [index: 'GET']

    def index() {
        render(
                status     : 200,
                contentType: 'application/json;charset=UTF-8',
                text       : ([
                        status   : 'UP',
                        timestamp: Instant.now().toString()
                ] as JSON).toString()
        )
    }
}