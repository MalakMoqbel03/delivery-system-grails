package com.ubs.delivery

class ApiResponseService {

    ApiResponse ok(Object data) {
        new ApiResponse(
                success   : true,
                message   : 'OK',
                data      : data,
                errors    : null,
                statusCode: 200
        )
    }

    ApiResponse created(Object data) {
        new ApiResponse(
                success   : true,
                message   : 'Created',
                data      : data,
                errors    : null,
                statusCode: 201
        )
    }

    ApiResponse notFound(String msg) {
        new ApiResponse(
                success   : false,
                message   : msg,
                data      : null,
                errors    : null,
                statusCode: 404
        )
    }

    ApiResponse badRequest(Map errors) {
        new ApiResponse(
                success   : false,
                message   : 'Validation failed',
                data      : null,
                errors    : errors,
                statusCode: 400
        )
    }

    ApiResponse serverError(String msg) {
        new ApiResponse(
                success   : false,
                message   : msg,
                data      : null,
                errors    : null,
                statusCode: 500
        )
    }
    ApiResponse unauthorized(String msg) {
        new ApiResponse(
                success   : false,
                message   : msg,
                data      : null,
                errors    : null,
                statusCode: 401
        )
    }

    Map extractErrors(def grailsErrors) {
        Map result = [:]

        grailsErrors?.fieldErrors?.each { error ->
            String field   = error.field
            String message = resolveMessage(error)
            if (!result[field]) result[field] = []
            result[field] << message
        }

        grailsErrors?.globalErrors?.each { error ->
            String message = resolveMessage(error)
            if (!result['_global']) result['_global'] = []
            result['_global'] << message
        }

        return result
    }


    private static String resolveMessage(def error) {
        if (error.defaultMessage) return error.defaultMessage

        String code = error.codes ? error.codes[0] : 'invalid'

        String shortCode = code.tokenize('.')?.last() ?: code

        Map<String, String> friendlyMessages = [
                'nullable'   : 'must not be null',
                'blank'      : 'must not be blank',
                'unique'     : 'must be unique',
                'min.notmet' : 'is below the minimum value',
                'max.notmet' : 'exceeds the maximum value',
                'size.toosmall': 'is too short',
                'size.toobig'  : 'is too long',
                'email'      : 'must be a valid email address',
                'url'        : 'must be a valid URL',
                'inList'     : 'is not a valid option',
                'matches'    : 'format is invalid',
                'creditCard' : 'must be a valid credit card number',
                'range'      : 'is out of range',
        ]

        return friendlyMessages[shortCode] ?: "is invalid (${shortCode})"
    }
}