package com.ubs.delivery

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification

class WarehouseSpec extends Specification implements DomainUnitTest<Warehouse> {

    void "test a valid Warehouse passes validation"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                maxCapacity: 200, currentLoad: 80)
        expect:
        wh.validate()
    }

    void "test maxCapacity is required"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                currentLoad: 80)
        expect:
        !wh.validate()
        wh.errors['maxCapacity']
    }

    void "test currentLoad is required"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                maxCapacity: 200)
        expect:
        !wh.validate()
        wh.errors['currentLoad']
    }

    void "test maxCapacity must be at least 1"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                maxCapacity: 0, currentLoad: 0)
        expect:
        !wh.validate()
        wh.errors['maxCapacity']
    }

    void "test hasSpace returns true when currentLoad < maxCapacity"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                maxCapacity: 100, currentLoad: 50)
        expect:
        wh.hasSpace()
    }

    void "test hasSpace returns false when full"() {
        given:
        def wh = new Warehouse(name: 'Central Hub', code: 'CH01', x: 0.0, y: 0.0,
                maxCapacity: 100, currentLoad: 100)
        expect:
        !wh.hasSpace()
    }
}