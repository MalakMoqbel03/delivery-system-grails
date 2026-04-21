package com.ubs.delivery

import grails.gorm.transactions.Transactional

@Transactional
class LocationService {

    EncryptionService encryptionService
    List<Location> list(params) {
        def max    = params?.max    ? params.int('max')    : 100
        def offset = params?.offset ? params.int('offset') : 0
        Location.executeQuery(
                'select l from Location l order by l.name asc',
                [:],
                [max: max, offset: offset]
        )
    }

    int count() {
        Location.executeQuery('select count(l) from Location l')[0] as int
    }

    Location get(Long id) {
        Location.get(id)
    }

    void delete(Long id) {
        Location.get(id)?.delete(flush: true)
    }
    Location save(Location location) {
        location.save(flush: true, failOnError: true)
    }


    Location saveWithCoords(Location location, Double plainX, Double plainY) {
        location.x = encryptionService.encryptCoordinate(plainX)
        location.y = encryptionService.encryptCoordinate(plainY)
        location.save(flush: true, failOnError: true)
    }


    Location updateCoords(Location location, Double plainX, Double plainY) {
        location.x = encryptionService.encryptCoordinate(plainX)
        location.y = encryptionService.encryptCoordinate(plainY)
        location.save(flush: true, failOnError: true)
    }

    Map decryptToMap(Location loc) {
        if (!loc) return null
        Double dx = encryptionService.decryptCoordinate(loc.x)
        Double dy = encryptionService.decryptCoordinate(loc.y)
        [
                id  : loc.id,
                name: loc.name,
                code: loc.code,
                x   : dx,
                y   : dy,
                type: loc.class.simpleName
        ]
    }

    List<Location> getAllSortedByDistance() {
        List<Location> all = Location.executeQuery('select l from Location l')
        all.sort { loc ->
            Double dx = encryptionService.decryptCoordinate(loc.x) ?: 0.0
            Double dy = encryptionService.decryptCoordinate(loc.y) ?: 0.0
            Math.hypot(dx, dy)
        }
        return all
    }

    List<DeliveryPoint> getHighPriorityDeliveries() {
        DeliveryPoint.executeQuery(
                'select dp from DeliveryPoint dp where dp.priority = :p order by dp.name asc',
                [p: 'HIGH']
        )
    }

    List<Warehouse> getWarehousesWithSpace() {
        Warehouse.executeQuery(
                'select w from Warehouse w where w.currentLoad < w.maxCapacity order by w.name asc'
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
        results.collect { loc -> decryptToMap(loc) }
    }

    String getAIInsight(Location location) {
        String result
        Double dx = encryptionService.decryptCoordinate(location.x) ?: 0.0
        Double dy = encryptionService.decryptCoordinate(location.y) ?: 0.0

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
            result = "General location ${location.name} at (${dx}, ${dy})."
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