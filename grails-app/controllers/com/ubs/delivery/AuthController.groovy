package com.ubs.delivery

class AuthController {

    AuthService authService
    static allowedMethods = [doLogin: 'POST', logout: 'GET']
    def login() {
        if (session.userId) {
            // Route to the right dashboard based on role
            if (session.role == 'ADMIN') {
                redirect controller: 'dashboard', action: 'index'
            } else {
                redirect controller: 'userDashboard', action: 'index'
            }
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
            session.returnUrl = null

            flash.message = "Welcome back, ${user.username}!"

            if (returnUrl && !returnUrl.contains('/dashboard/index') && !returnUrl.contains('/userDashboard')) {
                redirect(url: returnUrl)
            } else if (user.role == 'ADMIN') {
                redirect controller: 'dashboard', action: 'index'
            } else {
                redirect controller: 'userDashboard', action: 'index'
            }
        } else {
            flash.error = 'Invalid username or password.'
            redirect action: 'login'
        }
    }

    def logout() {
        session.invalidate()
        flash.message = 'You have been logged out.'
        redirect action: 'login'
    }

    /** Shown when a USER tries to access an admin-only page. */
    def forbidden() {
        response.status = 403
    }
}
