package com.ubs.delivery

import grails.converters.JSON

class ApiDeliveryAssignmentController {

    DeliveryAssignmentService deliveryAssignmentService
    ApiResponseService apiResponseService

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            delete: 'DELETE'
    ]
    def index() {
        try {
            def assignments = deliveryAssignmentService.list()

            def data = [
                    items : assignments,
                    total : assignments.size()
            ]

            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            renderApi(apiResponseService.serverError('Failed to fetch delivery assignments'))
        }
    }
    def show(Long id) {
        try {
            def assignment = deliveryAssignmentService.get(id)

            if (!assignment) {
                renderApi(apiResponseService.notFound('Assignment not found'))
                return
            }

            renderApi(apiResponseService.ok(assignment))
        } catch (Exception e) {
            renderApi(apiResponseService.serverError('Failed to fetch assignment'))
        }
    }
    def save() {
        try {
            def json = request.JSON

            Long warehouseId = json.warehouseId as Long
            Long deliveryPointId = json.deliveryPointId as Long
            String status = json.status

            def assignment = deliveryAssignmentService.create(warehouseId, deliveryPointId, status)

            if (assignment.hasErrors()) {
                Map errors = apiResponseService.extractErrors(assignment.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            renderApi(apiResponseService.created(assignment))
        } catch (Exception e) {
            renderApi(apiResponseService.serverError('Failed to create assignment'))
        }
    }
    def delete(Long id) {
        try {
            def assignment = deliveryAssignmentService.get(id)

            if (!assignment) {
                renderApi(apiResponseService.notFound('Assignment not found'))
                return
            }
            deliveryAssignmentService.delete(id)
            renderApi(apiResponseService.ok([id: id, deleted: true]))
        } catch (IllegalArgumentException e) {
            renderApi(apiResponseService.notFound('Assignment not found'))
        } catch (Exception e) {
            renderApi(apiResponseService.serverError('Failed to delete assignment'))
        }
    }

    private void renderApi(ApiResponse responseObj) {
        render status: responseObj.statusCode,
                contentType: 'application/json',
                text: (responseObj as JSON).toString()
    }
}