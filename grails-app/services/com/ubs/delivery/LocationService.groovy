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

    /**
     * FIX 3 — RENAMED from save() to saveWithCoords() AND fixed encryption.
     *
     * Two problems existed here:
     *
     * (a) The method was called save() but both LocationApiV1Controller and
     *     LocationApiV2Controller called locationService.saveWithCoords(). This
     *     caused a MissingMethodException on every POST request.
     *
     * (b) The original body did:
     *         location.x = plainX.toString().bytes
     *         location.y = plainY.toString().bytes
     *     This stored the coordinate as plain UTF-8 bytes — completely unencrypted.
     *     Any SELECT on the location table would expose the raw lat/lon values.
     *     The fix calls encryptionService.encryptCoordinate() so AES-256-GCM
     *     ciphertext is what actually lands in the bytea column.
     */
    Location saveWithCoords(Location location, Double plainX, Double plainY) {
        // ── 2-column encryption benchmark ────────────────────────────────────
        // Times only the AES-256-GCM work for the two coordinate columns (x, y).
        // The DB insert itself is measured separately so the timing is pure crypto.
        encryptionBenchmarkService.timeEncryption(2) {
            location.x = encryptionService.encryptCoordinate(plainX)
            location.y = encryptionService.encryptCoordinate(plainY)
        }
        location.save(flush: true, failOnError: true)
        return location
    }

    /**
     * saveWithFourEncryptedCoords — 4-column encryption benchmark variant.
     *
     * Encrypts four coordinate values (x, y, plus two additional fields) so
     * you can compare the encryption overhead of 4 encrypted columns vs 2.
     * The extra values (plainX2, plainY2) are re-encrypted into x and y again
     * here for demo purposes; in a real schema they would map to new bytea
     * columns on a richer domain object.
     *
     * Times only the four encryptCoordinate() calls — the DB save is outside
     * the timed block, just like in saveWithCoords above.
     */
    Location saveWithFourEncryptedCoords(Location location,
                                         Double plainX,  Double plainY,
                                         Double plainX2, Double plainY2) {
        // ── 4-column encryption benchmark ────────────────────────────────────
        byte[] encX2
        byte[] encY2
        encryptionBenchmarkService.timeEncryption(4) {
            location.x = encryptionService.encryptCoordinate(plainX)
            location.y = encryptionService.encryptCoordinate(plainY)
            encX2      = encryptionService.encryptCoordinate(plainX2)
            encY2      = encryptionService.encryptCoordinate(plainY2)
        }
        // encX2 / encY2 are captured above; attach to location or log as needed.
        // If your schema gains extra bytea columns later, assign them here.
        location.save(flush: true, failOnError: true)
        return location
    }

    /**
     * FIX 4 — updateCoords() also stored plain bytes instead of encrypting.
     *
     * Same root cause as saveWithCoords above: .toString().bytes writes
     * plain text. Replaced with encryptionService.encryptCoordinate().
     */
    Location updateCoords(Location location, Double plainX, Double plainY) {
        location.x = encryptionService.encryptCoordinate(plainX)
        location.y = encryptionService.encryptCoordinate(plainY)
        location.save(flush: true, failOnError: true)
        return location
    }

    /**
     * FIX 5 — save(Location) single-argument overload.
     *
     * LocationApiV1Controller.update() called locationService.save(location)
     * with ONE argument when x/y were not included in the PUT body. The old
     * service only had save(location, plainX, plainY) with THREE arguments,
     * so that call also caused a MissingMethodException. This overload lets
     * a partial update (name/code only) proceed without re-encrypting coords.
     */
    Location save(Location location) {
        location.save(flush: true, failOnError: true)
        return location
    }

    Map decryptToMap(Location loc) {
        if (!loc) return null
        // decryptCoords() now exists in EncryptionService (FIX 1)
        Map coords = encryptionService.decryptCoords(loc)
        [
                id  : loc.id,
                name: loc.name,
                code: loc.code,
                x   : coords.x,
                y   : coords.y,
                type: loc.class.simpleName
        ]
    }

    List<Location> getAllSortedByDistance() {
        List<Location> all = Location.executeQuery('select l from Location l')
        all.sort { loc ->
            // decryptCoords() now exists — no more MissingMethodException
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
        // decryptCoords() now exists — no more MissingMethodException
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