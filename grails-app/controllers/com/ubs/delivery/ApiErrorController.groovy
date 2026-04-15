package com.ubs.delivery

import grails.converters.JSON

class ApiErrorController {

    ApiResponseService apiResponseService

    def notFound() {
        def responseObj = apiResponseService.notFound('Resource not found')
        render status: 404, contentType: 'application/json', text: (responseObj as JSON).toString()
    }
    def serverError() {
        def responseObj = apiResponseService.serverError('Internal server error')
        render status: 500, contentType: 'application/json', text: (responseObj as JSON).toString()
    }
}