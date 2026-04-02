package com.ubs.delivery


class LocationService {

    List<Location> list(params) {
        Location.list(params)
    }

    int count() {
        Location.count()
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
        return Location.list().sort { location ->
            Math.sqrt(location.x * location.x + location.y * location.y)
        }
    }

    List<DeliveryPoint> getHighPriorityDeliveries() {
        return DeliveryPoint.findAllByPriority('HIGH')
    }

    List<Warehouse> getWarehousesWithSpace() {
        return Warehouse.withCriteria {
            ltProperty('currentLoad', 'maxCapacity')
        }
    }

    String getAIInsight(Location location) {
        if (location instanceof DeliveryPoint) {
            DeliveryPoint dp = (DeliveryPoint) location
            String timeAdvice = dp.priority == 'HIGH' ? 'Schedule immediately — this is urgent.'
                    : dp.priority == 'MEDIUM' ? 'Deliver within the next 24 hours.'
                    : 'Can be scheduled at your convenience.'
            return "Delivery to ${dp.deliveryArea}: ${timeAdvice} " +
                    "Distance from HQ: ${String.format('%.2f', Math.sqrt(dp.x*dp.x + dp.y*dp.y))} km."
        } else if (location instanceof Warehouse) {
            Warehouse wh = (Warehouse) location
            int pct = (int)((wh.currentLoad / wh.maxCapacity) * 100)
            String status = wh.hasSpace() ? 'has space available' : 'is FULL'
            return "Warehouse ${wh.name} ${status} (${pct}% full, ${wh.currentLoad}/${wh.maxCapacity} units)."
        }
        return "General location ${location.name} at coordinates (${location.x}, ${location.y})."
    }
}