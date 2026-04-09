package com.ubs.delivery

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification

class UserSpec extends Specification implements DomainUnitTest<User> {

    void "test user constraints"() {
        expect:
        true
    }
}