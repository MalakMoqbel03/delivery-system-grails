package com.ubs.delivery

/** ── Difference between before() and after() ──────────────────────────────────

 before()  runs before the controller action executes
 Here we capture the start timestamp so we can measure duration later

 after()   runs after the controller action but before the view renders
 the response status code has been set by the controller
 Use it to: inspect/modify the response, perform post-action logic,persist audit data
    • Return false here only if you want to prevent view rendering, returning true is the normal path.


    before() ->  pre-action  (request visible, response not yet written)
    after() -> post-action (response status set, body not yet flushed)
    afterView() ->  post-render (response committed, read-only)
 */
class ApiLoggingInterceptor {

    ApiRequestLogService apiRequestLogService
    ApiLoggingInterceptor() {
        matchAll().matches(uri: '/api/**')
    }


    boolean before() {
        request.setAttribute('startTime', System.currentTimeMillis())
        return true
    }


    boolean after() {
        try {
            Long startTime  = request.getAttribute('startTime') as Long
            long durationMs = startTime ? (System.currentTimeMillis() - startTime) : 0L


            String authHeader = request.getHeader('Authorization')
            String tokenValue = (authHeader?.startsWith('Bearer '))
                    ? authHeader.substring(7).trim()
                    : null

            apiRequestLogService.save(
                    request.method,
                    request.forwardURI ?: request.requestURI,
                    tokenValue,
                    response.status,
                    durationMs
            )
        } catch (Exception e) {
            log.error("ApiLoggingInterceptor: failed to save request log", e)
        }

        return true
    }

    void afterView() {
    }
}