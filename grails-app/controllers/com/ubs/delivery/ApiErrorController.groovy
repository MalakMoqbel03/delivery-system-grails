package com.ubs.delivery

import grails.converters.JSON

class ApiErrorController {

    ApiResponseService apiResponseService


    def notFound() {
        String uri = request.forwardURI ?: request.requestURI ?: ''

        if (uri.startsWith('/api/')) {
            def responseObj = apiResponseService.notFound('Resource not found')
            render status: 404,
                    contentType: 'application/json;charset=UTF-8',
                    text: (responseObj.toMap() as JSON).toString()
        } else {
            // Let the GSP view handle it for browser requests
            response.status = 404
            render view: '/notFound'
        }
    }

    def serverError() {
        String uri = request.forwardURI ?: request.requestURI ?: ''

        if (uri.startsWith('/api/')) {
            def responseObj = apiResponseService.serverError('Internal server error')
            render status: 500,
                    contentType: 'application/json;charset=UTF-8',
                    text: (responseObj.toMap() as JSON).toString()
        } else {
            response.status = 500
            render view: '/error'
        }
    }
}