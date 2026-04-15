package com.ubs.delivery

import grails.converters.JSON
import grails.validation.ValidationException

class ApiDeliveryPointController {

    DeliveryPointService deliveryPointService
    ApiResponseService   apiResponseService

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            update: 'PUT',
            delete: 'DELETE'
    ]

    // GET /api/v1/deliveryPoints
    def index(Integer max) {
        try {
            params.max = Math.min(max ?: 10, 100)
            def items = deliveryPointService.list(params)
            def data  = [
                    items: items.collect { dpToMap(it) },
                    total: deliveryPointService.count()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("Failed to fetch delivery points", e)
            renderApi(apiResponseService.serverError('Failed to fetch delivery points'))
        }
    }

    // GET /api/v1/deliveryPoints/{id}
    def show(Long id) {
        try {
            def item = deliveryPointService.get(id)
            if (!item) {
                renderApi(apiResponseService.notFound('Delivery point not found'))
                return
            }
            renderApi(apiResponseService.ok(dpToMap(item)))
        } catch (Exception e) {
            log.error("Failed to fetch delivery point ${id}", e)
            renderApi(apiResponseService.serverError('Failed to fetch delivery point'))
        }
    }

    // POST /api/v1/deliveryPoints
    def save() {
        try {
            def item = new DeliveryPoint(request.JSON)
            if (!item.validate()) {
                def errors = apiResponseService.extractErrors(item.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            deliveryPointService.save(item)
            renderApi(apiResponseService.created(dpToMap(item)))
        } catch (ValidationException e) {
            def errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("Failed to create delivery point", e)
            renderApi(apiResponseService.serverError('Failed to create delivery point'))
        }
    }

    // PUT /api/v1/deliveryPoints/{id}
    def update(Long id) {
        try {
            def item = deliveryPointService.get(id)
            if (!item) {
                renderApi(apiResponseService.notFound('Delivery point not found'))
                return
            }
            item.properties = request.JSON
            if (!item.validate()) {
                def errors = apiResponseService.extractErrors(item.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            deliveryPointService.save(item)
            renderApi(apiResponseService.ok(dpToMap(item)))
        } catch (ValidationException e) {
            def errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("Failed to update delivery point ${id}", e)
            renderApi(apiResponseService.serverError('Failed to update delivery point'))
        }
    }

    // DELETE /api/v1/deliveryPoints/{id}
    def delete(Long id) {
        try {
            def item = deliveryPointService.get(id)
            if (!item) {
                renderApi(apiResponseService.notFound('Delivery point not found'))
                return
            }
            deliveryPointService.delete(id)
            renderApi(apiResponseService.ok([id: id, deleted: true]))
        } catch (Exception e) {
            log.error("Failed to delete delivery point ${id}", e)
            renderApi(apiResponseService.serverError('Failed to delete delivery point'))
        }
    }

    private Map dpToMap(DeliveryPoint dp) {
        if (!dp) return null
        [
                id          : dp.id,
                name        : dp.name,
                code        : dp.code,
                x           : dp.x,
                y           : dp.y,
                deliveryArea: dp.deliveryArea,
                priority    : dp.priority,
                type        : 'DeliveryPoint'
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