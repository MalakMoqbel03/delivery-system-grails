package com.ubs.delivery

import grails.gorm.transactions.Transactional

@Transactional
class LocationService {

    EncryptionService           encryptionService
    EncryptionBenchmarkService  encryptionBenchmarkService

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

    Location saveWithCoords(Location location, Double plainX, Double plainY) {
        encryptionBenchmarkService.timeEncryption(2) {
            location.x = encryptionService.encryptCoordinate(plainX)
            location.y = encryptionService.encryptCoordinate(plainY)
        }
        long insertStart = System.nanoTime()
        location.save(flush: true, failOnError: true)
        encryptionBenchmarkService.recordInsert(2, System.nanoTime() - insertStart)
        return location
    }

    Location saveWithFourEncryptedCoords(Location location,
                                         Double plainX,  Double plainY,
                                         Double plainX2, Double plainY2) {
        byte[] encX2
        byte[] encY2
        encryptionBenchmarkService.timeEncryption(4) {
            location.x = encryptionService.encryptCoordinate(plainX)
            location.y = encryptionService.encryptCoordinate(plainY)
            encX2      = encryptionService.encryptCoordinate(plainX2)
            encY2      = encryptionService.encryptCoordinate(plainY2)
        }
        long insertStart = System.nanoTime()
        location.save(flush: true, failOnError: true)
        encryptionBenchmarkService.recordInsert(4, System.nanoTime() - insertStart)
        return location
    }

    Location updateCoords(Location location, Double plainX, Double plainY) {
        location.x = encryptionService.encryptCoordinate(plainX)
        location.y = encryptionService.encryptCoordinate(plainY)
        location.save(flush: true, failOnError: true)
        return location
    }

    Location save(Location location) {
        location.save(flush: true, failOnError: true)
        return location
    }

    /**
     * Decrypts coordinates and returns a flat map safe to serialise as JSON.
     * Includes warehouse-specific fields (maxCapacity, currentLoad) when the
     * location is a Warehouse so the warehouse index table can render the
     * capacity bar correctly.
     */
    Map decryptToMap(Location loc) {
        if (!loc) return null
        Map coords = encryptionService.decryptCoords(loc)
        Map result = [
                id  : loc.id,
                name: loc.name,
                code: loc.code,
                x   : coords.x,
                y   : coords.y,
                type: loc.class.simpleName
        ]
        // Add warehouse-specific fields so the JS capacity bar has real data
        if (loc instanceof Warehouse) {
            result.maxCapacity  = loc.maxCapacity
            result.currentLoad  = loc.currentLoad
        }
        // Add delivery-point-specific fields for completeness
        if (loc instanceof DeliveryPoint) {
            result.deliveryArea = loc.deliveryArea
            result.priority     = loc.priority
        }
        return result
    }

    List<Location> getAllSortedByDistance() {
        List<Location> all = Location.executeQuery('select l from Location l')
        all.sort { loc ->
            Map coords = encryptionService.decryptCoords(loc)
            Math.hypot(coords.x ?: 0.0, coords.y ?: 0.0)
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
        String trimmed = q?.trim() ?: ''
        List<Location> results
        if (trimmed) {
            results = Location.executeQuery(
                    "select l from Location l where (lower(l.name) like :q or lower(l.code) like :q) order by l.name asc",
                    [q: "%${trimmed.toLowerCase()}%"],
                    [max: 50]
            )
        } else {
            results = Location.executeQuery(
                    "select l from Location l order by l.name asc",
                    [:],
                    [max: 50]
            )
        }
        results.collect { loc -> decryptToMap(loc) }
    }

    String getAIInsight(Location location) {
        Map coords = encryptionService.decryptCoords(location)
        Double dx = coords.x ?: 0.0
        Double dy = coords.y ?: 0.0
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
            result = "General location ${location.code} at (${dx}, ${dy})."
        }
        if (result.length() > 200) result = result.substring(0, 197) + '...'
        new AIQueryLog(
                locationCode : location.code,
                queryType    : location.class.simpleName,
                aiResponse   : result,
                aggregatedAt : truncateToHour(new Date())
        ).save(flush: true, failOnError: true)
        return result
    }

    private static Date truncateToHour(Date d) {
        Calendar cal = Calendar.getInstance()
        cal.setTime(d)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.getTime()
    }
}
