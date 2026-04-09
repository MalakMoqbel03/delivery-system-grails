package com.ubs.delivery


class DeliveryPoint extends Location {
    static hasMany = [assignments: DeliveryAssignment]
    String deliveryArea
    String priority

    static constraints = {
        deliveryArea nullable: false, blank: false
        priority     nullable: false, inList: ['LOW', 'MEDIUM', 'HIGH']
    }
}