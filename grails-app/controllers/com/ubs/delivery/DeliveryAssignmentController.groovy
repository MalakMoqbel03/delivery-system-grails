package com.ubs.delivery

import grails.gorm.transactions.Transactional

class DeliveryAssignmentController {
    DeliveryAssignmentService deliveryAssignmentService
    static allowedMethods = [save: "POST", delete: ["DELETE", "POST"]]
    def index() {
        def assignments = deliveryAssignmentService.list()
        [assignmentList: assignments, assignmentCount: assignments.size()]
    }
    def create() {
        [
                warehouses    : Warehouse.list(sort: 'name'),
                deliveryPoints: DeliveryPoint.list(sort: 'name'),
                assignment    : new DeliveryAssignment()
        ]
    }
    /* Delegates all creation logic (validation, duplicate check) to the service */
    @Transactional
    def save() {
        try {
            deliveryAssignmentService.create(params.long('warehouse.id'), params.long('deliveryPoint.id'), params.status)
            flash.message = "Assignment created successfully"
            redirect action: 'index'
        } catch (IllegalArgumentException | IllegalStateException e) {
            flash.message = e.message
            redirect action: 'create'
        }
    }

    @Transactional
    def delete(Long id) {
        try {
            deliveryAssignmentService.delete(id)
            flash.message = "Assignment deleted"
        } catch (IllegalArgumentException e) {
            flash.message = e.message
        }
        redirect action: 'index'
    }
}
