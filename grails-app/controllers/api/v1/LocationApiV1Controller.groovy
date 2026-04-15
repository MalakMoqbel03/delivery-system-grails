package api.v1
import com.ubs.delivery.ApiResponse
import com.ubs.delivery.ApiResponseService
import com.ubs.delivery.DeliveryPoint
import com.ubs.delivery.Location
import com.ubs.delivery.LocationService
import com.ubs.delivery.Warehouse
import grails.converters.JSON
import grails.validation.ValidationException

class LocationApiV1Controller {

    LocationService    locationService
    ApiResponseService apiResponseService
    static namespace = 'api.v1'

    static allowedMethods = [
            index : 'GET',
            show  : 'GET',
            save  : 'POST',
            update: 'PUT',
            delete: 'DELETE'
    ]

    // GET /api/v1/locations
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
            log.error("V1 - Failed to fetch locations", e)
            renderApi(apiResponseService.serverError('Failed to fetch locations'))
        }
    }

    // GET /api/v1/locations/{id}
    def show(Long id) {
        try {
            def location = locationService.get(id)
            if (!location) {
                renderApi(apiResponseService.notFound('Location not found'))
                return
            }
            renderApi(apiResponseService.ok(locationToMap(location)))
        } catch (Exception e) {
            log.error("V1 - Failed to fetch location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to fetch location'))
        }
    }

    // POST /api/v1/locations
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
            log.error("V1 - Failed to create location", e)
            renderApi(apiResponseService.serverError('Failed to create location'))
        }
    }

    // PUT /api/v1/locations/{id}
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
            log.error("V1 - Failed to update location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to update location'))
        }
    }

    // DELETE /api/v1/locations/{id}
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
            log.error("V1 - Failed to delete location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to delete location'))
        }
    }

    private Map locationToMap(Location loc) {
        if (!loc) return null
        [
                id  : loc.id,
                name: loc.name,
                x   : loc.x,
                y   : loc.y,
                type: loc.class.simpleName
        ]

    }

    private void renderApi(ApiResponse responseObj) {
        response.addHeader('X-API-Version', 'v1')
        response.addHeader('X-Deprecated', 'true')

        render(
                status     : responseObj.statusCode,
                contentType: 'application/json;charset=UTF-8',
                text       : (responseObj.toMap() as JSON).toString()
        )
    }
}