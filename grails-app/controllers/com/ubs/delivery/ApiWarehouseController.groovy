package com.ubs.delivery

import grails.converters.JSON
import grails.validation.ValidationException

class ApiWarehouseController {

    WarehouseService   warehouseService
    ApiResponseService apiResponseService

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            update: 'PUT',
            delete: 'DELETE'
    ]

    // GET /api/v1/warehouses
    def index(Integer max) {
        try {
            params.max = Math.min(max ?: 10, 100)
            def warehouses = warehouseService.list(params)
            def data = [
                    items: warehouses.collect { warehouseToMap(it) },
                    total: warehouseService.count()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("Failed to fetch warehouses", e)
            renderApi(apiResponseService.serverError('Failed to fetch warehouses'))
        }
    }

    // GET /api/v1/warehouses/{id}
    def show(Long id) {
        try {
            def warehouse = warehouseService.get(id)
            if (!warehouse) {
                renderApi(apiResponseService.notFound('Warehouse not found'))
                return
            }
            renderApi(apiResponseService.ok(warehouseToMap(warehouse)))
        } catch (Exception e) {
            log.error("Failed to fetch warehouse ${id}", e)
            renderApi(apiResponseService.serverError('Failed to fetch warehouse'))
        }
    }

    // POST /api/v1/warehouses
    def save() {
        try {
            def warehouse = new Warehouse(request.JSON)
            if (!warehouse.validate()) {
                Map errors = apiResponseService.extractErrors(warehouse.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            warehouseService.save(warehouse)
            renderApi(apiResponseService.created(warehouseToMap(warehouse)))
        } catch (ValidationException e) {
            Map errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("Failed to create warehouse", e)
            renderApi(apiResponseService.serverError('Failed to create warehouse'))
        }
    }

    // PUT /api/v1/warehouses/{id}
    def update(Long id) {
        try {
            def warehouse = warehouseService.get(id)
            if (!warehouse) {
                renderApi(apiResponseService.notFound('Warehouse not found'))
                return
            }
            warehouse.properties = request.JSON
            if (!warehouse.validate()) {
                Map errors = apiResponseService.extractErrors(warehouse.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            warehouseService.save(warehouse)
            renderApi(apiResponseService.ok(warehouseToMap(warehouse)))
        } catch (ValidationException e) {
            Map errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("Failed to update warehouse ${id}", e)
            renderApi(apiResponseService.serverError('Failed to update warehouse'))
        }
    }

    // DELETE /api/v1/warehouses/{id}
    def delete(Long id) {
        try {
            def warehouse = warehouseService.get(id)
            if (!warehouse) {
                renderApi(apiResponseService.notFound('Warehouse not found'))
                return
            }
            warehouseService.delete(id)
            renderApi(apiResponseService.ok([id: id, deleted: true]))
        } catch (Exception e) {
            log.error("Failed to delete warehouse ${id}", e)
            renderApi(apiResponseService.serverError('Failed to delete warehouse'))
        }
    }

    private Map warehouseToMap(Warehouse wh) {
        if (!wh) return null
        [
                id         : wh.id,
                name       : wh.name,
                code       : wh.code,
                x          : wh.x,
                y          : wh.y,
                maxCapacity: wh.maxCapacity,
                currentLoad: wh.currentLoad,
                hasSpace   : wh.hasSpace(),
                type       : 'Warehouse'
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