package com.ubs.delivery


class DeliveryPoint extends Location {

    String deliveryArea
    String priority

    static constraints = {
        deliveryArea nullable: false, blank: false
        priority     nullable: false, inList: ['LOW', 'MEDIUM', 'HIGH']
    }
}