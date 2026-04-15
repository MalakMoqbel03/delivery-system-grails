package com.ubs.delivery

import grails.converters.JSON

class ApiDeliveryAssignmentController {

    DeliveryAssignmentService deliveryAssignmentService
    ApiResponseService        apiResponseService

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            delete: 'DELETE'
    ]
    // GET /api/v1/deliveryAssignments
    def index() {
        try {
            def assignments = deliveryAssignmentService.list()
            def data = [
                    items: assignments.collect { assignmentToMap(it) },
                    total: assignments.size()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("Failed to fetch delivery assignments", e)
            renderApi(apiResponseService.serverError('Failed to fetch delivery assignments'))
        }
    }

    // GET /api/v1/deliveryAssignments/{id}
    def show(Long id) {
        try {
            def assignment = deliveryAssignmentService.get(id)
            if (!assignment) {
                renderApi(apiResponseService.notFound('Assignment not found'))
                return
            }
            renderApi(apiResponseService.ok(assignmentToMap(assignment)))
        } catch (Exception e) {
            log.error("Failed to fetch assignment ${id}", e)
            renderApi(apiResponseService.serverError('Failed to fetch assignment'))
        }
    }

    // POST /api/v1/deliveryAssignments
    def save() {
        try {
            def json             = request.JSON
            Long warehouseId     = json.warehouseId as Long
            Long deliveryPointId = json.deliveryPointId as Long
            String status        = json.status

            def assignment = deliveryAssignmentService.create(warehouseId, deliveryPointId, status)

            if (assignment.hasErrors()) {
                Map errors = apiResponseService.extractErrors(assignment.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            renderApi(apiResponseService.created(assignmentToMap(assignment)))
        } catch (Exception e) {
            log.error("Failed to create assignment", e)
            renderApi(apiResponseService.serverError('Failed to create assignment'))
        }
    }

    // DELETE /api/v1/deliveryAssignments/{id}
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
            log.error("Failed to delete assignment ${id}", e)
            renderApi(apiResponseService.serverError('Failed to delete assignment'))
        }
    }

    private Map assignmentToMap(DeliveryAssignment a) {
        if (!a) return null
        [
                id               : a.id,
                status           : a.status,

                assignedAt       : a.assignedAt?.format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
                warehouseId      : a.warehouse?.id,
                warehouseName    : a.warehouse?.name,
                deliveryPointId  : a.deliveryPoint?.id,
                deliveryPointName: a.deliveryPoint?.name
        ]
    }

    private void renderApi(ApiResponse responseObj) {
        render(
                status     : responseObj.statusCode,
                contentType: 'application/json;charset=UTF-8',
                text       : (responseObj.toMap() as JSON).toString()
        )
    }
}