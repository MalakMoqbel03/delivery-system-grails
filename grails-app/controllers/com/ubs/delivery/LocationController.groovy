package com.ubs.delivery

import grails.converters.JSON
import grails.validation.ValidationException

class LocationController {
    LocationService   locationService
    EncryptionService encryptionService

    static allowedMethods = [save: 'POST', update: ['PUT', 'POST'], delete: ['DELETE', 'POST']]

    def index() {
        List<Location> locations = Location.list(sort: "name", order: "asc")

        def locationRows = locations.collect { loc ->
            Map coords = encryptionService.decryptCoords(loc)

            [
                    id   : loc.id,
                    name : loc.name,
                    code : loc.code,
                    type : loc.class.simpleName,
                    x    : coords.x,
                    y    : coords.y
            ]
        }

        [
                locationList : locationRows,
                locationCount: locationRows.size()
        ]
    }

    def show(Long id) {
        def loc = locationService.get(id)
        if (!loc) { notFound(); return }
        Map coords = encryptionService.decryptCoords(loc)
        render view: 'show', model: [location: loc, plainX: coords.x, plainY: coords.y]
    }

    def create() {
        render view: 'create', model: [location: new Location(params)]
    }

    def save() {
        def json = request.JSON
        def location = new Location()
        location.name = json.name
        location.code = json.code
        Double plainX = json.x as Double
        Double plainY = json.y as Double
        if (!plainX || !plainY) {
            render(status: 400, text: 'x and y coordinates are required')
            return
        }
        try {
            locationService.saveWithCoords(location, plainX, plainY)
            render(locationService.decryptToMap(location) as JSON)
        } catch (Exception e) {
            render(status: 400, text: "Error saving location: ${e.message}")
        }
    }

    def edit(Long id) {
        def loc = locationService.get(id)
        if (!loc) { notFound(); return }
        Map coords = encryptionService.decryptCoords(loc)
        render view: 'edit', model: [location: loc, plainX: coords.x, plainY: coords.y]
    }

    def update(Location location) {
        if (location == null) { notFound(); return }
        try {
            Double plainX = params.x as Double
            Double plainY = params.y as Double
            if (plainX != null && plainY != null) {
                locationService.updateCoords(location, plainX, plainY)
            } else {
                locationService.save(location)
            }
        } catch (ValidationException e) {
            render view: 'edit', model: [location: location]
            return
        }
        flash.message = "Location '${location.name}' updated."
        redirect action: 'index'
    }

    def delete(Long id) {
        if (id == null) { notFound(); return }
        locationService.delete(id)
        flash.message = 'Location deleted.'
        redirect action: 'index', method: 'GET'
    }

    // JSON endpoint used by warehouse & location index pages via fetch()
    def search() {
        render locationService.search(params.q) as JSON
    }

    def highPriority() {
        def results = locationService.getHighPriorityDeliveries()
        render view: 'highPriority', model: [highPriorityPoints: results, deliveryList: results]
    }

    def warehousesWithSpace() {
        // Decrypt coordinates for each warehouse before passing to view
        def decryptedList = locationService.getWarehousesWithSpace().collect { wh ->
            Map coords = encryptionService.decryptCoords(wh)
            [instance: wh, plainX: coords.x, plainY: coords.y]
        }
        render view: 'warehousesWithSpace', model: [warehouseList: decryptedList]
    }

    def sortedByDistance() {
        // Decrypt and compute distance for each location before passing to view
        def decryptedList = locationService.getAllSortedByDistance().collect { loc ->
            Map coords = encryptionService.decryptCoords(loc)
            Double dx = coords.x ?: 0.0
            Double dy = coords.y ?: 0.0
            [instance: loc, plainX: dx, plainY: dy, distance: Math.hypot(dx, dy)]
        }
        render view: 'sortedByDistance', model: [locationList: decryptedList]
    }

    def insight(Long id) {
        def location = Location.get(id)
        if (!location) {
            flash.message = 'Location not found'
            redirect action: 'index'
            return
        }
        render view: 'insight', model: [location: location, insight: locationService.getAIInsight(location)]
    }

    def ajaxInsight(Long id) {
        def location = Location.get(id)
        if (!location) { render status: 404, text: 'Location not found'; return }
        render locationService.getAIInsight(location)
    }

    def history() {
        render view: 'history', model: [logList: AIQueryLog.list()]
    }

    protected void notFound() {
        flash.message = 'Location not found'
        redirect action: 'index', method: 'GET'
    }
}
