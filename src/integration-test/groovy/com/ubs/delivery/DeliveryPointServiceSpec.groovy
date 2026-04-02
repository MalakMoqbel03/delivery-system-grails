package com.ubs.delivery

import grails.testing.mixin.integration.Integration
import grails.gorm.transactions.Rollback
import spock.lang.Specification
import org.hibernate.SessionFactory

@Integration
@Rollback
class DeliveryPointServiceSpec extends Specification {

    DeliveryPointService deliveryPointService
    SessionFactory sessionFactory

    private Long setupData() {
        // TODO: Populate valid domain instances and return a valid ID
        //new DeliveryPoint(...).save(flush: true, failOnError: true)
        //new DeliveryPoint(...).save(flush: true, failOnError: true)
        //DeliveryPoint deliveryPoint = new DeliveryPoint(...).save(flush: true, failOnError: true)
        //new DeliveryPoint(...).save(flush: true, failOnError: true)
        //new DeliveryPoint(...).save(flush: true, failOnError: true)
        assert false, "TODO: Provide a setupData() implementation for this generated test suite"
        //deliveryPoint.id
    }

    void "test get"() {
        setupData()

        expect:
        deliveryPointService.get(1) != null
    }

    void "test list"() {
        setupData()

        when:
        List<DeliveryPoint> deliveryPointList = deliveryPointService.list(max: 2, offset: 2)

        then:
        deliveryPointList.size() == 2
        assert false, "TODO: Verify the correct instances are returned"
    }

    void "test count"() {
        setupData()

        expect:
        deliveryPointService.count() == 5
    }

    void "test delete"() {
        Long deliveryPointId = setupData()

        expect:
        deliveryPointService.count() == 5

        when:
        deliveryPointService.delete(deliveryPointId)
        sessionFactory.currentSession.flush()

        then:
        deliveryPointService.count() == 4
    }

    void "test save"() {
        when:
        assert false, "TODO: Provide a valid instance to save"
        DeliveryPoint deliveryPoint = new DeliveryPoint()
        deliveryPointService.save(deliveryPoint)

        then:
        deliveryPoint.id != null
    }
}
