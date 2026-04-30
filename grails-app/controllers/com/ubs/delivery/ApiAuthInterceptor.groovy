package com.ubs.delivery

import grails.converters.JSON

class ApiAuthInterceptor {

    ApiResponseService apiResponseService
    RateLimiterService rateLimiterService
    AuthService        authService
    ApiAuthInterceptor() {
        match(uri: '/api/**')  // use match() not matchAll().matches()
    }

    boolean before() {
        String authHeader = request.getHeader('Authorization')

        if (!authHeader?.startsWith('Bearer ')) {
            renderJson(apiResponseService.unauthorized('Unauthorized'), 401)
            return false
        }

        String tokenValue = authHeader.substring(7).trim()
        if (!tokenValue) {
            renderJson(apiResponseService.unauthorized('Unauthorized'), 401)
            return false
        }

        ApiToken apiToken = authService.findActiveToken(tokenValue)
        if (!apiToken) {
            renderJson(apiResponseService.unauthorized('Unauthorized'), 401)
            return false
        }

        request.apiClientName = apiToken.clientName
        request.apiTokenId    = apiToken.id

        boolean allowed = rateLimiterService.isAllowed(tokenValue)
        response.addHeader('X-RateLimit-Limit',     String.valueOf(RateLimiterService.MAX_REQUESTS))
        response.addHeader('X-RateLimit-Remaining', String.valueOf(rateLimiterService.remaining(tokenValue)))

        if (!allowed) {
            renderJson(
                    new ApiResponse(
                            success   : false,
                            message   : 'Rate limit exceeded. Try again later.',
                            data      : null,
                            errors    : null,
                            statusCode: 429
                    ),
                    429
            )
            return false
        }

        return true
    }

    boolean after()  { true }
    void afterView() {}

    private void renderJson(ApiResponse apiResponse, int status) {
        response.status      = status
        response.contentType = 'application/json;charset=UTF-8'
        render(apiResponse.toMap() as JSON)
    }
}