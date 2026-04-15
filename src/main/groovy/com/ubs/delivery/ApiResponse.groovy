package com.ubs.delivery

import grails.converters.JSON


class ApiResponse {

    boolean success
    String  message
    Object  data
    Map     errors
    int     statusCode

    Map toMap() {
        [
                success   : success,
                message   : message,
                data      : flattenData(data),
                errors    : errors,
                statusCode: statusCode
        ]
    }


    private static Object flattenData(Object obj) {
        if (obj == null) return null

        if (obj instanceof Map)    return obj
        if (obj instanceof String) return obj
        if (obj instanceof Number) return obj
        if (obj instanceof Boolean) return obj
        if (obj instanceof Collection) {
            return obj.collect { flattenData(it) }
        }
        try {
            def map = [:]
            def props = obj.class.declaredFields
                    .findAll { !it.synthetic && it.name != 'metaClass' }
                    .collect { it.name }

            // Use standard GORM-style property access
            if (obj.hasProperty('id'))          map.id          = obj.id
            if (obj.hasProperty('name'))        map.name        = obj.name
            if (obj.hasProperty('code'))        map.code        = obj.code
            if (obj.hasProperty('x'))           map.x           = obj.x
            if (obj.hasProperty('y'))           map.y           = obj.y

            // Location subclasses
            if (obj.hasProperty('maxCapacity')) map.maxCapacity = obj.maxCapacity
            if (obj.hasProperty('currentLoad')) map.currentLoad = obj.currentLoad
            if (obj.hasProperty('deliveryArea'))map.deliveryArea= obj.deliveryArea
            if (obj.hasProperty('priority'))    map.priority    = obj.priority

            // DeliveryAssignment
            if (obj.hasProperty('status'))      map.status      = obj.status
            if (obj.hasProperty('assignedAt'))  map.assignedAt  = obj.assignedAt

            if (obj.hasProperty('warehouse') && obj.warehouse) {
                map.warehouseId   = obj.warehouse?.id
                map.warehouseName = obj.warehouse?.name
            }
            if (obj.hasProperty('deliveryPoint') && obj.deliveryPoint) {
                map.deliveryPointId   = obj.deliveryPoint?.id
                map.deliveryPointName = obj.deliveryPoint?.name
            }

            map['_type'] = obj.class.simpleName

            return map.isEmpty() ? obj.toString() : map
        } catch (Exception e) {
            return obj.toString()
        }
    }
}