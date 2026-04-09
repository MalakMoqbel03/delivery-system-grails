package com.ubs.delivery

import grails.gorm.transactions.Transactional

@Transactional
class LocationService {

    List<Location> list(params) {
        def max    = params?.max    ? params.int('max')    : 100
        def offset = params?.offset ? params.int('offset') : 0
        Location.executeQuery(
                "select l from Location l order by l.name asc",
                [:],
                [max: max, offset: offset]
        )
    }

    int count() {
        Location.executeQuery("select count(l) from Location l")[0] as int
    }

    Location get(Long id) {
        Location.get(id)
    }

    Location save(Location location) {
        location.save(flush: true, failOnError: true)
    }

    void delete(Long id) {
        Location.get(id)?.delete(flush: true)
    }

    List<Location> getAllSortedByDistance() {
        Location.executeQuery("select l from Location l order by (l.x * l.x + l.y * l.y) asc"
        )
    }

    List<DeliveryPoint> getHighPriorityDeliveries() {
        DeliveryPoint.executeQuery(
                "select dp from DeliveryPoint dp where dp.priority = :p order by dp.name asc",
                [p: 'HIGH']
        )
    }

    List<Warehouse> getWarehousesWithSpace() {
        Warehouse.executeQuery(
                "select w from Warehouse w where w.currentLoad < w.maxCapacity order by w.name asc"
        )
    }

    List<Map> search(String q) {
        def results = Location.withCriteria {
            or {
                eq('class', Warehouse)
                eq('class', DeliveryPoint)
            }
            if (q && q.trim()) {
                or {
                    ilike('name', "%${q.trim()}%")
                    ilike('code', "%${q.trim()}%")
                }
            }
            order('name', 'asc')
            maxResults(50)
        }
        results.collect { loc ->
            def map = [
                    id  : loc.id,
                    name: loc.name,
                    code: loc.code,
                    x   : loc.x,
                    y   : loc.y,
                    type: loc.class.simpleName
            ]
            if (loc instanceof Warehouse) {
                map.maxCapacity = loc.maxCapacity
                map.currentLoad = loc.currentLoad
            }
            if (loc instanceof DeliveryPoint) {
                map.deliveryArea = loc.deliveryArea
                map.priority     = loc.priority
            }
            map
        }
    }
    String getAIInsight(Location location) {
        String result
        if (location instanceof DeliveryPoint) {
            DeliveryPoint dp = (DeliveryPoint) location
            String timeAdvice = dp.priority == 'HIGH'   ? 'Schedule immediately — this is urgent.'
                    : dp.priority == 'MEDIUM' ? 'Deliver within the next 24 hours.'
                    :                           'Can be scheduled at your convenience.'
            result = "Delivery to ${dp.deliveryArea}: ${timeAdvice}"
        } else if (location instanceof Warehouse) {
            Warehouse wh = (Warehouse) location
            result = "Warehouse ${wh.name} ${wh.hasSpace() ? 'has space available' : 'is FULL'} (${wh.currentLoad}/${wh.maxCapacity})."
        } else {
            result = "General location ${location.name} at (${location.x}, ${location.y})."
        }

        new AIQueryLog(
                locationCode: location.code,
                locationName: location.name,
                queryType   : location.class.simpleName,
                aiResponse  : result
        ).save(flush: true, failOnError: true)

        return result
    }
}
