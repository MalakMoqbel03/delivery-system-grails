package com.ubs.delivery

import grails.gorm.transactions.Transactional
import grails.validation.ValidationException
import static org.springframework.http.HttpStatus.*

class DeliveryPointController {

    DeliveryPointService deliveryPointService
    EncryptionService    encryptionService

    static allowedMethods = [save: "POST", update: ["PUT","POST"], delete: ["DELETE","POST"]]

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        def rawList          = deliveryPointService.list(params)
        def deliveryPointCount = deliveryPointService.count()
        // Decrypt coordinates for each delivery point so the view can display plain values
        def deliveryPointList = rawList.collect { dp ->
            Map coords = encryptionService.decryptCoords(dp)
            [instance: dp, plainX: coords.x, plainY: coords.y]
        }
        render view: 'index', model: [deliveryPointList: deliveryPointList, deliveryPointCount: deliveryPointCount]
    }

    def show(Long id) {
        def deliveryPoint = deliveryPointService.get(id)
        if (!deliveryPoint) { notFound(); return }
        Map coords = encryptionService.decryptCoords(deliveryPoint)

        // Average status weight: PENDING=1, IN_TRANSIT=2, DELIVERED=3
        def assignments = deliveryPoint.assignments
        double avgStatusWeight = 0
        if (assignments) {
            def weightMap = [PENDING: 1, IN_TRANSIT: 2, DELIVERED: 3]
            def total = assignments.sum { weightMap[it.status] ?: 0 }
            avgStatusWeight = total / assignments.size()
        }
        render view: 'show', model: [
                deliveryPoint: deliveryPoint,
                plainX: coords.x,
                plainY: coords.y,
                avgStatusWeight: avgStatusWeight
        ]
    }

    def create() {
        render view: 'create', model: [deliveryPoint: new DeliveryPoint(params)]
    }

    @Transactional(readOnly = true)
    def checkCode(String code) {
        String cleanCode = code?.trim()?.toUpperCase()?.replace("_", "")
        boolean available = !Location.findByCode(cleanCode)

        render([available: available] as grails.converters.JSON)
    }

    def save() {
        String code = params.code?.trim()?.toUpperCase()?.replace("_", "")

        if (!code) {
            flash.message = "Code is required"
            redirect(action: "create")
            return
        }

        if (Location.findByCode(code)) {
            flash.message = "Code already exists. Please use another code."
            redirect(action: "create")
            return
        }

        Double plainX = params.double('x')
        Double plainY = params.double('y')

        if (plainX == null || plainY == null) {
            flash.message = "X and Y coordinates are required."
            redirect(action: "create")
            return
        }

        try {
            DeliveryPoint deliveryPoint = new DeliveryPoint(
                    name        : params.name,
                    code        : code,
                    deliveryArea: params.deliveryArea,
                    priority    : params.priority
            )

            deliveryPoint.x = encryptionService.encryptCoordinate(plainX)
            deliveryPoint.y = encryptionService.encryptCoordinate(plainY)

            deliveryPoint.save(failOnError: true, flush: true)

            flash.message = "Delivery point created successfully"
            redirect(action: "index")
        } catch (Exception e) {
            e.printStackTrace()
            flash.message = "Error creating delivery point: ${e.message}"
            redirect(action: "create")
        }
    }

    def edit(Long id) {
        def deliveryPoint = deliveryPointService.get(id)
        if (!deliveryPoint) { notFound(); return }
        Map coords = encryptionService.decryptCoords(deliveryPoint)
        render view: 'edit', model: [deliveryPoint: deliveryPoint, plainX: coords.x, plainY: coords.y]
    }

    def update(DeliveryPoint deliveryPoint) {
        if (deliveryPoint == null) { notFound(); return }
        try {
            deliveryPointService.save(deliveryPoint)
        } catch (ValidationException e) {
            render view: 'edit', model: [deliveryPoint: deliveryPoint]
            return
        }
        flash.message = message(code: 'default.updated.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), deliveryPoint.id])
        redirect action: 'show', id: deliveryPoint.id
    }

    def delete(Long id) {
        if (id == null) { notFound(); return }
        deliveryPointService.delete(id)
        flash.message = message(code: 'default.deleted.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), id])
        redirect action: 'index', method: 'GET'
    }

    protected void notFound() {
        flash.message = message(code: 'default.not.found.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), params.id])
        redirect action: 'index', method: 'GET'
    }
}
