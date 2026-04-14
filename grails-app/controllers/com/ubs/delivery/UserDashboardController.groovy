package com.ubs.delivery

import grails.gorm.transactions.Transactional

class UserDashboardController {

    def index() {
        def allAssignments = DeliveryAssignment.executeQuery(
                """select a from DeliveryAssignment a
               join fetch a.warehouse w
               join fetch a.deliveryPoint dp
               order by a.assignedAt desc"""
        )

        def pending    = allAssignments.findAll { it.status == 'PENDING' }
        def inTransit  = allAssignments.findAll { it.status == 'IN_TRANSIT' }
        def delivered  = allAssignments.findAll { it.status == 'DELIVERED' }

        [
                allAssignments : allAssignments,
                pending        : pending,
                inTransit      : inTransit,
                delivered      : delivered,
                pendingCount   : pending.size(),
                inTransitCount : inTransit.size(),
                deliveredCount : delivered.size(),
                totalCount     : allAssignments.size()
        ]
    }

    @Transactional
    def updateStatus(Long id) {
        def assignment = DeliveryAssignment.get(id)
        if (!assignment) {
            flash.error = 'Assignment not found.'
            redirect action: 'index'
            return
        }

        String next = nextStatus(assignment.status)
        if (!next) {
            flash.error = 'This assignment is already delivered.'
            redirect action: 'index'
            return
        }

        assignment.status = next
        if (!assignment.save(flush: true)) {
            flash.error = "Could not update status: ${assignment.errors}"
            redirect action: 'index'
            return
        }

        flash.message = "Assignment updated to ${next}."
        redirect action: 'index'
    }


    private static String nextStatus(String current) {
        switch (current) {
            case 'PENDING'    : return 'IN_TRANSIT'
            case 'IN_TRANSIT' : return 'DELIVERED'
            default           : return null
        }
    }
}
