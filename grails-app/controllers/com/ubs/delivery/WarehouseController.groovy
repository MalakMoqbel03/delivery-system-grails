package com.ubs.delivery
import grails.converters.JSON

import grails.gorm.transactions.Transactional
import grails.validation.ValidationException
import static org.springframework.http.HttpStatus.*

class WarehouseController {

    WarehouseService  warehouseService
    LocationService   locationService
    EncryptionService encryptionService

    static allowedMethods = [save: "POST", update: ["PUT","POST"], delete: ["DELETE","POST"]]

    def index() {
        List<Warehouse> warehouses = Warehouse.list(sort: "name", order: "asc")

        def warehouseRows = warehouses.collect { wh ->
            [
                    id          : wh.id,
                    name        : wh.name,
                    code        : wh.code,
                    x : encryptionService.decryptCoordinate(wh.x),
                    y : encryptionService.decryptCoordinate(wh.y),
                    currentLoad : wh.currentLoad ?: 0,
                    maxCapacity : wh.maxCapacity ?: 0
            ]
        }

        [
                warehouseList : warehouseRows,
                warehouseCount: warehouseRows.size()
        ]
    }

    def show(Long id) {
        def warehouse = warehouseService.get(id)
        if (!warehouse) { notFound(); return }
        Map coords = encryptionService.decryptCoords(warehouse)
        render view: 'show', model: [warehouse: warehouse, plainX: coords.x, plainY: coords.y]
    }

    def create() {
        render view: 'create', model: [warehouse: new Warehouse(params)]
    }

    @Transactional(readOnly = true)
    def checkCode(String code) {
        def available = !Location.findByCode(code?.trim()?.toUpperCase())
        render([available: available] as JSON)
    }

    def save() {
        Double plainX = params.double('x')
        Double plainY = params.double('y')
        if (plainX == null || plainY == null) {
            flash.message = 'X and Y coordinates are required.'
            render view: 'create', model: [warehouse: new Warehouse(params)]
            return
        }
        def warehouse = new Warehouse(
                name:        params.name,
                code:        params.code,
                maxCapacity: params.int('maxCapacity'),
                currentLoad: params.int('currentLoad') ?: 0
        )
        try {
            locationService.saveWithCoords(warehouse, plainX, plainY)
        } catch (ValidationException e) {
            render view: 'create', model: [warehouse: warehouse]
            return
        }
        flash.message = message(code: 'default.created.message', args: [message(code: 'warehouse.label', default: 'Warehouse'), warehouse.id])
        redirect action: 'show', id: warehouse.id
    }

    def edit(Long id) {
        def warehouse = warehouseService.get(id)
        if (!warehouse) { notFound(); return }
        Map coords = encryptionService.decryptCoords(warehouse)
        render view: 'edit', model: [warehouse: warehouse, plainX: coords.x, plainY: coords.y]
    }

    def update(Long id) {
        def warehouse = warehouseService.get(id)
        if (warehouse == null) { notFound(); return }
        warehouse.name        = params.name
        warehouse.code        = params.code
        warehouse.maxCapacity = params.int('maxCapacity')
        warehouse.currentLoad = params.int('currentLoad') ?: 0
        Double plainX = params.double('x')
        Double plainY = params.double('y')
        try {
            if (plainX != null && plainY != null) {
                locationService.updateCoords(warehouse, plainX, plainY)
            } else {
                warehouseService.save(warehouse)
            }
        } catch (ValidationException e) {
            render view: 'edit', model: [warehouse: warehouse]
            return
        }
        flash.message = message(code: 'default.updated.message', args: [message(code: 'warehouse.label', default: 'Warehouse'), warehouse.id])
        redirect action: 'show', id: warehouse.id
    }

    def delete(Long id) {
        if (id == null) { notFound(); return }
        warehouseService.delete(id)
        flash.message = message(code: 'default.deleted.message', args: [message(code: 'warehouse.label', default: 'Warehouse'), id])
        redirect action: 'index', method: 'GET'
    }

    protected void notFound() {
        flash.message = message(code: 'default.not.found.message', args: [message(code: 'warehouse.label', default: 'Warehouse'), params.id])
        redirect action: 'index', method: 'GET'
    }
}
