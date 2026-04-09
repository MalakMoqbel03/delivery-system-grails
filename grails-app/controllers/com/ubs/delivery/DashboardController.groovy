package com.ubs.delivery

class DashboardController {
    LocationService locationService
    def index() {
        def warehousesCount = Warehouse.count()
        def deliveryPointsCount = DeliveryPoint.count()
        def locationsCount = Location.count()
        def assignmentCount = DeliveryAssignment.count()
        def activeAssignments = DeliveryAssignment.where { status in ['PENDING', 'IN_TRANSIT'] }.count()
        def highPriorityDeliveriesCount = DeliveryPoint.where { priority == 'HIGH' }.count()
        def warehousesWithSpaceCount = locationService.getWarehousesWithSpace()?.size() ?: 0
        def priorityHigh = DeliveryPoint.where { priority == 'HIGH' }.count()
        def priorityMedium = DeliveryPoint.where { priority == 'MEDIUM' }.count()
        def priorityLow = DeliveryPoint.where { priority == 'LOW' }.count()
        def recentAssignments = DeliveryAssignment.list(sort: 'assignedAt', order: 'desc', max: 7
        )
        def locationOptions = Location.executeQuery(
                """select l from Location l
                       where type(l) in (DeliveryPoint, Warehouse)
                       order by l.name asc""",
                        [:], [max: 40]
        )
        [
                warehousesCount: warehousesCount,
                deliveryPointsCount: deliveryPointsCount,
                locationsCount: locationsCount,
                assignmentCount: assignmentCount,
                activeAssignments: activeAssignments,
                highPriorityDeliveriesCount: highPriorityDeliveriesCount,
                warehousesWithSpaceCount: warehousesWithSpaceCount,
                priorityHigh: priorityHigh,
                priorityMedium: priorityMedium,
                priorityLow: priorityLow,
                recentAssignments: recentAssignments,
                locationOptions: locationOptions
        ]
    }
}