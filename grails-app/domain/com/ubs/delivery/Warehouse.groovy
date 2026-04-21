package com.ubs.delivery

class Warehouse extends Location {
    static hasMany = [assignments: DeliveryAssignment]
    Integer maxCapacity
    Integer currentLoad

    static constraints = {
        maxCapacity nullable: false, min: 1
        currentLoad nullable: false, min: 0
    }
    static mapping = {
        table 'warehouse'
    }

    boolean hasSpace() {
        return currentLoad < maxCapacity
    }
}