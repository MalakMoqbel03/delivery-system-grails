package com.ubs.delivery

import grails.converters.JSON
import grails.validation.ValidationException
import static org.springframework.http.HttpStatus.*

class LocationController {
    LocationService locationService
    static allowedMethods = [save: "POST", update: ["PUT","POST"], delete: ["DELETE","POST"]]
    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        def locationList  = locationService.list(params)
        def locationCount = locationService.count()
        [locationList: locationList, locationCount: locationCount]
    }

    def show(Long id) {
        def loc = locationService.get(id)
        if (!loc) { notFound(); return }
        [location: loc]
    }

    def create() {
        respond new Location(params)
    }

    def save(Location location) {
        if (location == null) { notFound(); return }
        try {
            locationService.save(location)
        } catch (ValidationException e) {
            respond location.errors, view: 'create'
            return
        }
        flash.message = "Location '${location.name}' created."
        redirect action: "index"
    }

    def edit(Long id) {
        def loc = locationService.get(id)
        if (!loc) { notFound(); return }
        [location: loc]
    }

    def update(Location location) {
        if (location == null) { notFound(); return }
        try {
            locationService.save(location)
        } catch (ValidationException e) {
            respond location.errors, view: 'edit'
            return
        }
        flash.message = "Location '${location.name}' updated."
        redirect action: "index"
    }

    def delete(Long id) {
        if (id == null) { notFound(); return }
        locationService.delete(id)
        flash.message = "Location deleted."
        redirect action: "index", method: "GET"
    }



    def search() {
        String q = params.q
        def results = locationService.search(q)
        render results as JSON
    }


    def highPriority() {
        def results = locationService.getHighPriorityDeliveries()
        [highPriorityPoints: results, deliveryList: results]
    }
    def warehousesWithSpace() {
        def results = locationService.getWarehousesWithSpace()
        [warehouseList: results]
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
        [location: location, insight: locationService.getAIInsight(location)]
    }

    def ajaxInsight(Long id) {
        def location = Location.get(id)
        if (!location) { render status: 404, text: "Location not found"; return }
        render locationService.getAIInsight(location)
    }

    def history() {
        [logList: AIQueryLog.list()]
    }

    protected void notFound() {
        flash.message = "Location not found"
        redirect action: "index", method: "GET"
    }
}