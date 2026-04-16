package com.ubs.delivery


class ApiResponse {

    boolean success
    String  message
    Object  data
    Map     errors
    int     statusCode

    Map toMap() {
        [
                success   : success,
                message   : message,
                data      : data,
                errors    : errors,
                statusCode: statusCode
        ]
    }
    @Override
    String toString() {
        "ApiResponse[statusCode=${statusCode}, success=${success}, message='${message}']"
    }
}