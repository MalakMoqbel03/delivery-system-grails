package com.ubs.delivery

import grails.gorm.services.Service

@Service(DeliveryPoint)
interface DeliveryPointService {

    DeliveryPoint get(Serializable id)

    List<DeliveryPoint> list(Map args)
    Long count()
    void delete(Serializable id)
    DeliveryPoint save(DeliveryPoint deliveryPoint)

}