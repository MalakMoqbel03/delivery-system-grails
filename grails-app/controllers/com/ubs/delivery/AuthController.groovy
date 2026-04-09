package com.ubs.delivery

class AuthController {

    AuthService authService
    static allowedMethods = [doLogin: 'POST', logout: 'GET']
    def login() {
        if (session.userId) {
            redirect controller: 'dashboard', action: 'index'
            return
        }
        [error: flash.error]
    }

    def doLogin() {
        String username = params.username?.trim()?.toLowerCase()
        String password = params.password
        User user = authService.authenticate(username, password)

        if (user) {
            session.userId   = user.id
            session.username = user.username
            session.role     = user.role
            String returnUrl = session.returnUrl
            session.returnUrl = null  // clear it
            flash.message = "Welcome back, ${user.username}!"
            if (returnUrl) {
                redirect(url: returnUrl)
            } else {
                redirect controller: 'dashboard', action: 'index'
            }
        } else {
            flash.error = 'Invalid username or password.'
            redirect action: 'login'
        }
    }
    def logout() {
        session.invalidate()   // wipes ALL session data
        flash.message = 'You have been logged out.'
        redirect action: 'login'
    }
}
