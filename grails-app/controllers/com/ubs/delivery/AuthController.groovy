package com.ubs.delivery

import grails.gorm.transactions.Transactional


class AuthController {

    DataMinimizationService dataMinimizationService
    AuthService             authService


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
                phone        : body.phone,        // may be null
                dateOfBirth  : dob,               // may be null
                fullAddress  : body.fullAddress,  // may be null
                role         : 'USER'
        ]

        try {
            User user = dataMinimizationService.minimizeAndSave(rawInput)
            render status: 201, contentType: 'application/json', text: ([
                    success : true,
                    pseudoId: user.pseudoId,   // return pseudoId, NOT the real DB id
                    username: user.username
            ] as grails.converters.JSON).toString()
        } catch (Exception e) {
            render status: 400, contentType: 'application/json', text: ([
                    success: false,
                    error  : e.message
            ] as grails.converters.JSON).toString()
        }
    }



    @Transactional
    def login() {
        def body = request.JSON
        User user = authService.authenticate(body.username as String, body.password as String)

        if (!user) {
            render status: 401, contentType: 'application/json', text: ([
                    success: false, error: 'Invalid credentials'
            ] as grails.converters.JSON).toString()
            return
        }

        user.lastLoginAt = new Date()
        user.save(flush: true)

        session['userId'] = user.id
        session['role']   = user.role

        render contentType: 'application/json', text: ([
                success : true,
                pseudoId: user.pseudoId,
                role    : user.role
        ] as grails.converters.JSON).toString()
    }


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


    def userView() {
        Long   targetId    = params.long('id')
        String requestRole = session['role'] as String ?: 'DEFAULT'

        Map view = dataMinimizationService.getUserView(targetId, requestRole)
        render contentType: 'application/json', text: (view as grails.converters.JSON).toString()
    }
}