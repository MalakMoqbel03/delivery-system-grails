package com.ubs.delivery

class DeliveryAssignment {

    String status
    Date   assignedAt = new Date()

    static belongsTo = [
            warehouse    : Warehouse,
            deliveryPoint: DeliveryPoint
    ]

    static constraints = {
        status        nullable: false, inList: ['PENDING', 'IN_TRANSIT', 'DELIVERED']
        assignedAt    nullable: false
        warehouse     nullable: false
        deliveryPoint nullable: false
    }

    static mapping = {
        table 'delivery_assignment'
    }
    @Override
    String toString() {
        return "${warehouse?.name} → ${deliveryPoint?.name} [${status}]"
    }
}