package api.v2
import com.ubs.delivery.ApiResponse
import com.ubs.delivery.ApiResponseService
import com.ubs.delivery.DeliveryPoint
import com.ubs.delivery.Location
import com.ubs.delivery.LocationService
import com.ubs.delivery.Warehouse
import grails.converters.JSON
import grails.validation.ValidationException

class LocationApiV2Controller {

    LocationService    locationService
    ApiResponseService apiResponseService
    static namespace = 'api.v2'

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            update: 'PUT',
            delete: 'DELETE'
    ]

    // GET /api/v2/locations
    def index(Integer max) {
        try {
            params.max = Math.min(max ?: 10, 100)
            def locations = locationService.list(params)
            def data = [
                    items: locations.collect { locationToMap(it) },
                    total: locationService.count()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("V2 - Failed to fetch locations", e)
            renderApi(apiResponseService.serverError('Failed to fetch locations'))
        }
    }

    // GET /api/v2/locations/{id}
    def show(Long id) {
        try {
            def location = locationService.get(id)
            if (!location) {
                renderApi(apiResponseService.notFound('Location not found'))
                return
            }
            renderApi(apiResponseService.ok(locationToMap(location)))
        } catch (Exception e) {
            log.error("V2 - Failed to fetch location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to fetch location'))
        }
    }

    // POST /api/v2/locations
    def save() {
        try {
            def location = new Location(request.JSON)
            if (!location.validate()) {
                def errors = apiResponseService.extractErrors(location.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            locationService.save(location)
            renderApi(apiResponseService.created(locationToMap(location)))
        } catch (ValidationException e) {
            def errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("V2 - Failed to create location", e)
            renderApi(apiResponseService.serverError('Failed to create location'))
        }
    }

    // PUT /api/v2/locations/{id}
    def update(Long id) {
        try {
            def location = locationService.get(id)
            if (!location) {
                renderApi(apiResponseService.notFound('Location not found'))
                return
            }
            bindData(location, request.JSON, [include: ['name', 'code', 'x', 'y']])
            if (!location.validate()) {
                def errors = apiResponseService.extractErrors(location.errors)
                renderApi(apiResponseService.badRequest(errors))
                return
            }
            locationService.save(location)
            renderApi(apiResponseService.ok(locationToMap(location)))
        } catch (ValidationException e) {
            def errors = apiResponseService.extractErrors(e.errors)
            renderApi(apiResponseService.badRequest(errors))
        } catch (Exception e) {
            log.error("V2 - Failed to update location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to update location'))
        }
    }

    // DELETE /api/v2/locations/{id}
    def delete(Long id) {
        try {
            def location = locationService.get(id)
            if (!location) {
                renderApi(apiResponseService.notFound('Location not found'))
                return
            }
            locationService.delete(id)
            renderApi(apiResponseService.ok([id: id, deleted: true]))
        } catch (Exception e) {
            log.error("V2 - Failed to delete location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to delete location'))
        }
    }

    private Map locationToMap(Location loc) {
        if (!loc) return null

        double distance = Math.hypot(loc.x ?: 0.0, loc.y ?: 0.0)

        Map map = [
                id                : loc.id,
                name              : loc.name,
                coordinates       : [
                                             x: loc.x,
                                             y: loc.y
                ],
                type              : loc.class.simpleName,
                distanceFromOrigin: Math.round(distance * 100) / 100.0
        ]

        if (loc instanceof DeliveryPoint) {
            def latestAssignment = com.ubs.delivery.DeliveryAssignment
                    .findByDeliveryPoint(loc, [sort: 'assignedAt', order: 'desc', max: 1])
            map.warehouseId = latestAssignment?.warehouse?.id  // null if none
        }

        map
    }

    private void renderApi(ApiResponse responseObj) {
        response.addHeader('X-API-Version', 'v2')
        render(
                status     : responseObj.statusCode,
                contentType: 'application/json;charset=UTF-8',
                text       : (responseObj.toMap() as JSON).toString()
        )
    }
}