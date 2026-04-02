package com.ubs.delivery

import grails.validation.ValidationException
import static org.springframework.http.HttpStatus.*

class LocationController {
    LocationService locationService
    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]
    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond locationService.list(params), model: [locationCount: locationService.count()]
    }

    def show(Long id) {
        respond locationService.get(id)
    }

    def create() {
        respond new Location(params)
    }

    def save(Location location) {
        if (location == null) {
            notFound()
            return
        }

        try {
            locationService.save(location)
        } catch (ValidationException e) {
            respond location.errors, view: 'create'
            return
        }

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'location.label', default: 'Location'), location.id])
                redirect location
            }
            '*' { respond location, [status: CREATED] }
        }
    }

    def edit(Long id) {
        respond locationService.get(id)
    }

    def update(Location location) {
        if (location == null) {
            notFound()
            return
        }

        try {
            locationService.save(location)
        } catch (ValidationException e) {
            respond location.errors, view: 'edit'
            return
        }

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'location.label', default: 'Location'), location.id])
                redirect location
            }
            '*' { respond location, [status: OK] }
        }
    }

    def delete(Long id) {
        if (id == null) {
            notFound()
            return
        }

        locationService.delete(id)

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'location.label', default: 'Location'), id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NO_CONTENT }
        }
    }
    def highPriority() {
        def results = DeliveryPoint.findAllByPriority('HIGH')
        [deliveryList: results]
    }
    def warehousesWithSpace() {
        def results = Warehouse.withCriteria {
            ltProperty('currentLoad', 'maxCapacity')
            order('name', 'asc')
        }
        [warehouseList: results]
    }
    def hqlExample() {
        def results = DeliveryPoint.executeQuery(
                "from DeliveryPoint where priority = :p order by name",
                [p: 'HIGH']
        )
        [deliveryList: results]
    }
    def sortedByDistance() {
        [locationList: locationService.getAllSortedByDistance()]
    }
    def insight(Long id) {
        def location = Location.get(id)
        if (!location) {
            flash.message = "Location not found"
            redirect action: 'index'
            return
        }
        String insight = locationService.getAIInsight(location)
        [location: location, insight: insight]
    }
    def ajaxInsight(Long id) {
        def location = Location.get(id)
        if (!location) {
            render status: 404, text: "Location not found"
            return
        }
        render locationService.getAIInsight(location)
    }
    def history() {
        [logList: AIQueryLog.list()]
    }
    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'location.label', default: 'Location'), params.id])
                redirect action: "index", method: "GET"
            }
            '*' { render status: NOT_FOUND }
        }
    }
}