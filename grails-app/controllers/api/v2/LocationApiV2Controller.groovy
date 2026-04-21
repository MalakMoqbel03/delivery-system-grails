package api.v2

import com.ubs.delivery.AIQueryLog
import com.ubs.delivery.ApiResponse
import com.ubs.delivery.ApiResponseService
import com.ubs.delivery.DeliveryAssignment
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
            index          : 'GET',
            show           : 'GET',
            save           : 'POST',
            update         : 'PUT',
            delete         : 'DELETE',
            insight        : 'GET',
            highPriority   : 'GET',
            sortedByDistance: 'GET',
            search         : 'GET',
            aiLog          : 'GET'
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
            log.error('V2 - Failed to fetch locations', e)
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
            def json = request.JSON
            def location = new Location()
            location.name = json.name
            location.code = json.code

            Double plainX = json.x as Double
            Double plainY = json.y as Double

            if (plainX == null || plainY == null) {
                renderApi(apiResponseService.badRequest([coordinates: ['x and y are required']]))
                return
            }

            locationService.saveWithCoords(location, plainX, plainY)

            if (location.hasErrors()) {
                renderApi(apiResponseService.badRequest(apiResponseService.extractErrors(location.errors)))
                return
            }

            renderApi(apiResponseService.created(locationToMap(location)))
        } catch (ValidationException e) {
            renderApi(apiResponseService.badRequest(apiResponseService.extractErrors(e.errors)))
        } catch (Exception e) {
            log.error('V2 - Failed to create location', e)
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

            def json = request.JSON
            if (json.name) location.name = json.name
            if (json.code) location.code = json.code

            Double plainX = json.x as Double
            Double plainY = json.y as Double

            if (plainX != null && plainY != null) {
                locationService.updateCoords(location, plainX, plainY)
            } else {
                locationService.save(location)
            }
            renderApi(apiResponseService.ok(locationToMap(location)))
        } catch (ValidationException e) {
            renderApi(apiResponseService.badRequest(apiResponseService.extractErrors(e.errors)))
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

    // GET /api/v2/locations/{id}/insight
    def insight(Long id) {
        try {
            def location = locationService.get(id)
            if (!location) {
                renderApi(apiResponseService.notFound('Location not found'))
                return
            }
            String insightText = locationService.getAIInsight(location)
            def data = [
                    locationId  : location.id,
                    locationName: location.name,
                    locationCode: location.code,
                    type        : location.class.simpleName,
                    insight     : insightText
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("V2 - Failed to get insight for location ${id}", e)
            renderApi(apiResponseService.serverError('Failed to get insight'))
        }
    }

    // GET /api/v2/locations/highPriority
    def highPriority() {
        try {
            def results = locationService.getHighPriorityDeliveries()
            def data = [
                    items: results.collect { locationToMap(it) },
                    total: results.size()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error('V2 - Failed to fetch high priority deliveries', e)
            renderApi(apiResponseService.serverError('Failed to fetch high priority deliveries'))
        }
    }

    // GET /api/v2/locations/sortedByDistance
    def sortedByDistance() {
        try {
            def results = locationService.getAllSortedByDistance()
            def data = [
                    items: results.collect { locationToMap(it) },
                    total: results.size()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error('V2 - Failed to fetch sorted locations', e)
            renderApi(apiResponseService.serverError('Failed to fetch sorted locations'))
        }
    }

    // GET /api/v2/locations/search?q=hub
    def search() {
        try {
            String q = params.q
            def results = locationService.search(q)
            renderApi(apiResponseService.ok([items: results, total: results.size()]))
        } catch (Exception e) {
            log.error('V2 - Failed to search locations', e)
            renderApi(apiResponseService.serverError('Failed to search locations'))
        }
    }

    // GET /api/v2/locations/aiLog
    def aiLog() {
        try {
            def logs = AIQueryLog.list(max: 50, sort: 'queriedAt', order: 'desc')
            def data = [
                    items: logs.collect { log ->
                        [
                                id          : log.id,
                                locationCode: log.locationCode,
                                locationName: log.locationName,
                                queryType   : log.queryType,
                                aiResponse  : log.aiResponse,
                                queriedAt   : log.queriedAt?.format("yyyy-MM-dd'T'HH:mm:ss'Z'")
                        ]
                    },
                    total: logs.size()
            ]
            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error('V2 - Failed to fetch AI logs', e)
            renderApi(apiResponseService.serverError('Failed to fetch AI logs'))
        }
    }

    private Map locationToMap(Location loc) {
        if (!loc) return null

        Map base = locationService.decryptToMap(loc)
        double dx = base.x ?: 0.0
        double dy = base.y ?: 0.0
        double distance = Math.hypot(dx, dy)

        Map map = [
                id                : loc.id,
                name              : loc.name,
                code              : loc.code,
                coordinates       : [x: dx, y: dy],
                type              : loc.class.simpleName,
                distanceFromOrigin: Math.round(distance * 100) / 100.0
        ]

        if (loc instanceof DeliveryPoint) {
            DeliveryPoint dp = (DeliveryPoint) loc
            map.deliveryArea = dp.deliveryArea
            map.priority     = dp.priority
            def latestAssignment = DeliveryAssignment
                    .findByDeliveryPoint(loc, [sort: 'assignedAt', order: 'desc', max: 1])
            map.warehouseId = latestAssignment?.warehouse?.id
        }

        if (loc instanceof Warehouse) {
            Warehouse wh = (Warehouse) loc
            map.maxCapacity = wh.maxCapacity
            map.currentLoad = wh.currentLoad
            map.hasSpace    = wh.hasSpace()
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