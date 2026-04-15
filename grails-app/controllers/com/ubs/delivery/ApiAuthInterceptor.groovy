package com.ubs.delivery

import grails.converters.JSON

class ApiAuthInterceptor {

    ApiResponseService apiResponseService

    ApiAuthInterceptor() {
        matchAll()
                .matches(uri: '/api/**')
                .excludes(uri: '/api/health')
    }

    boolean before() {
        String authHeader = request.getHeader('Authorization')

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            renderUnauthorized()
            return false
        }

        String tokenValue = authHeader.substring(7).trim()

        if (!tokenValue) {
            renderUnauthorized()
            return false
        }

        ApiToken apiToken = ApiToken.findByTokenAndActive(tokenValue, true)

        if (!apiToken) {
            renderUnauthorized()
            return false
        }

        request.apiClientName = apiToken.clientName
        request.apiTokenId    = apiToken.id

        return true
    }

    boolean after() { true }

    void afterView() {}

    private void renderUnauthorized() {
        def responseObj = apiResponseService.unauthorized('Unauthorized')

        response.status      = 401
        response.contentType = 'application/json;charset=UTF-8'
        render(responseObj.toMap() as JSON)
    }
}