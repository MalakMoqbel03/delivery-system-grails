package com.ubs.delivery

import grails.gorm.transactions.Transactional

class AuthController {

    DataMinimizationService dataMinimizationService
    AuthService             authService

    // GET /login — renders the login.gsp HTML page
    def login() {
        if (session.userId) {
            String role = session.role ?: 'ROLE_USER'
            if (role == 'ROLE_ADMIN') {
                redirect uri: '/dashboard'
            } else {
                redirect uri: '/my'
            }
            return
        }
        // renders grails-app/views/auth/login.gsp automatically
    }

    // POST /login — processes the HTML form submission
    @Transactional
    def doLogin() {
        String username = params.username
        String password = params.password

        User user = authService.authenticate(username, password)

        if (!user) {
            render view: 'login', model: [error: 'Invalid username or password']
            return
        }

        user.lastLoginAt = new Date()
        user.save(flush: true)

        session['userId'] = user.id
        session['role']   = user.role

        if (user.role == 'ROLE_ADMIN') {
            redirect uri: '/dashboard'
        } else {
            redirect uri: '/my'
        }
    }

    // GET /logout
    def logout() {
        session.invalidate()
        flash.message = 'You have been logged out.'
        redirect uri: '/login'
    }

    // GET /forbidden
    def forbidden() {
        render view: 'forbidden'
    }

    // POST /api/auth/register — JSON API
    @Transactional
    def register() {
        def body = request.JSON

        Date dob = null
        if (body.dateOfBirth) {
            try {
                dob = Date.parse('yyyy-MM-dd', body.dateOfBirth as String)
            } catch (Exception ignored) {
            }
        }

        Map rawInput = [
                username     : body.username,
                plainPassword: body.plainPassword,
                email        : body.email,
                phone        : body.phone,
                dateOfBirth  : dob,
                fullAddress  : body.fullAddress,
                role         : 'USER'
        ]

        try {
            User user = dataMinimizationService.minimizeAndSave(rawInput)
            render status: 201, contentType: 'application/json', text: ([
                    success : true,
                    pseudoId: user.pseudoId,
                    username: user.username
            ] as grails.converters.JSON).toString()
        } catch (Exception e) {
            render status: 400, contentType: 'application/json', text: ([
                    success: false,
                    error  : e.message
            ] as grails.converters.JSON).toString()
        }
    }

    // DELETE /auth/erase — JSON API
    @Transactional
    def erase() {
        Long targetId = params.long('userId') ?: session.long('userId')
        if (!targetId) {
            render status: 400, contentType: 'application/json', text: ([
                    success: false, error: 'userId required'
            ] as grails.converters.JSON).toString()
            return
        }

        Map result = dataMinimizationService.eraseUser(targetId)
        int status  = result.success ? 200 : 404
        render status: status, contentType: 'application/json',
                text: (result as grails.converters.JSON).toString()
    }

    // GET /auth/userView — JSON API
    def userView() {
        Long targetId = params.long('id')

        if (!targetId) {
            render status: 400, contentType: 'application/json', text: ([
                    success: false,
                    error  : 'id parameter is required'
            ] as grails.converters.JSON).toString()
            return
        }

        String requestRole = session['role'] as String ?: 'DEFAULT'

        try {
            Map view = dataMinimizationService.getUserView(targetId, requestRole)
            if (!view) {
                render status: 404, contentType: 'application/json', text: ([
                        success: false,
                        error  : "User with id ${targetId} not found"
                ] as grails.converters.JSON).toString()
                return
            }
            render contentType: 'application/json', text: (view as grails.converters.JSON).toString()
        } catch (Exception e) {
            render status: 500, contentType: 'application/json', text: ([
                    success: false,
                    error  : e.message
            ] as grails.converters.JSON).toString()
        }
    }
}