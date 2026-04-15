package com.ubs.delivery

import grails.gorm.transactions.Transactional

@Transactional
class DeliveryAssignmentService {

    List<DeliveryAssignment> list() {
        DeliveryAssignment.executeQuery(
                """select a from DeliveryAssignment a
                   join fetch a.warehouse w
                   join fetch a.deliveryPoint dp
                   order by a.assignedAt desc"""
        )
    }

    DeliveryAssignment get(Long id) {
        DeliveryAssignment.get(id)
    }

    DeliveryAssignment create(Long warehouseId, Long deliveryPointId, String status) {
        def warehouse = Warehouse.get(warehouseId)
        def deliveryPoint = DeliveryPoint.get(deliveryPointId)

        def assignment = new DeliveryAssignment(
                warehouse: warehouse,
                deliveryPoint: deliveryPoint,
                status: status
        )
        if (!warehouse) {
            assignment.errors.rejectValue('warehouse', 'deliveryAssignment.warehouse.notFound', 'Warehouse not found')
        }

        if (!deliveryPoint) {
            assignment.errors.rejectValue('deliveryPoint', 'deliveryAssignment.deliveryPoint.notFound', 'Delivery point not found')
        }
        if (warehouse && deliveryPoint) {
            boolean alreadyExists = DeliveryAssignment.withCriteria {
                eq('warehouse', warehouse)
                eq('deliveryPoint', deliveryPoint)
                maxResults(1)
            }.size() > 0

            if (alreadyExists) {
                assignment.errors.reject('deliveryAssignment.duplicate', 'Assignment already exists for this warehouse and delivery point')
            }
        }

        if (assignment.hasErrors() || !assignment.validate()) {
            return assignment
        }

        assignment.save(flush: true, failOnError: true)
        assignment
    }
    void delete(Long id) {
        def assignment = DeliveryAssignment.get(id)
        if (!assignment) {
            throw new IllegalArgumentException('Assignment not found')
        }
        assignment.delete(flush: true)
    }

    double calculateAverageStatusWeight(Long deliveryPointId) {
        def deliveryPoint = DeliveryPoint.get(deliveryPointId)
        if (!deliveryPoint) return 0.0

        def assignments = DeliveryAssignment.findAllByDeliveryPoint(deliveryPoint)
        if (!assignments) return 0.0

        def weights = [PENDING: 1, IN_TRANSIT: 2, DELIVERED: 3]
        double total = assignments.sum { weights[it.status] ?: 0 } as double
        return total / assignments.size()
    }
}