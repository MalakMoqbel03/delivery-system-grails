package com.ubs.delivery

import grails.gorm.transactions.Transactional
import grails.validation.ValidationException
import static org.springframework.http.HttpStatus.*

class DeliveryPointController {
    DeliveryPointService deliveryPointService
    static allowedMethods = [save: "POST", update: ["PUT","POST"], delete: ["DELETE","POST"]]
    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond deliveryPointService.list(params), model:[deliveryPointCount: deliveryPointService.count()]
    }
    def show(Long id) {
        respond deliveryPointService.get(id)
    }
    def create() {
        respond new DeliveryPoint(params)
    }
    @Transactional(readOnly = true)
    def checkCode(String code) {
        render(contentType: 'application/json') {
            [available: !DeliveryPoint.findByCode(code)]
        }
    }
    def save(DeliveryPoint deliveryPoint) {
        if (deliveryPoint == null) { notFound(); return }
        try {
            deliveryPointService.save(deliveryPoint)
        } catch (ValidationException e) {
            respond deliveryPoint.errors, view:'create'
            return
        }
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), deliveryPoint.id])
                redirect deliveryPoint
            }
            '*' { respond deliveryPoint, [status: CREATED] }
        }
    }
    def edit(Long id) { respond deliveryPointService.get(id) }

    def update(DeliveryPoint deliveryPoint) {
        if (deliveryPoint == null) { notFound(); return }
        try {
            deliveryPointService.save(deliveryPoint)
        } catch (ValidationException e) {
            respond deliveryPoint.errors, view:'edit'
            return
        }
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), deliveryPoint.id])
                redirect deliveryPoint
            }
            '*'{ respond deliveryPoint, [status: OK] }
        }
    }
    def delete(Long id) {
        if (id == null) { notFound(); return }
        deliveryPointService.delete(id)
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }
    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'deliveryPoint.label', default: 'DeliveryPoint'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }
}