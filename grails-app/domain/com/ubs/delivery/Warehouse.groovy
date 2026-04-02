package com.ubs.delivery


class Warehouse extends Location {

    Integer maxCapacity
    Integer currentLoad

    static constraints = {
        maxCapacity nullable: false, min: 1
        currentLoad nullable: false, min: 0
    }

    boolean hasSpace() {
        return currentLoad < maxCapacity
    }
}