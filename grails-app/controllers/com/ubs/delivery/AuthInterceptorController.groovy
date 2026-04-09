package com.ubs.delivery

class AuthInterceptor {
    AuthInterceptor() {
        matchAll()
                .excludes(controller: 'auth')
    }

    boolean before() {
        if (!session.userId) {
            session.returnUrl = request.forwardURI

            redirect controller: 'auth', action: 'login'
            return false
        }
        return true
    }

    boolean after() { true }
    void afterView() {}
}
