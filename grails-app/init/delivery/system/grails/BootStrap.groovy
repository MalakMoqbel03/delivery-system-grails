package delivery.system.grails

import com.ubs.delivery.DeliveryPoint
import com.ubs.delivery.Warehouse
import com.ubs.delivery.Location
import com.ubs.delivery.User
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

class BootStrap {

    def init = { servletContext ->

        if (User.count() == 0) {
            def encoder = new BCryptPasswordEncoder(10)

            new User(
                    username: 'admin',
                    password: encoder.encode('admin123'),
                    role: 'ADMIN',
                    enabled: true
            ).save(failOnError: true, flush: true)

            new User(
                    username: 'user',
                    password: encoder.encode('user123'),
                    role: 'USER',
                    enabled: true
            ).save(failOnError: true, flush: true)

            println ">>> BootStrap: created default users (admin / user)"
        }

        if (Location.count() == 0) {

            new DeliveryPoint(
                    name: 'Downtown Drop',
                    code: 'DP001',
                    x: 3.5,
                    y: 7.2,
                    deliveryArea: 'City Centre',
                    priority: 'HIGH'
            ).save(failOnError: true)

            new DeliveryPoint(
                    name: 'Suburb Stop',
                    code: 'DP002',
                    x: 10.0,
                    y: 4.0,
                    deliveryArea: 'North Suburbs',
                    priority: 'MEDIUM'
            ).save(failOnError: true)

            new DeliveryPoint(
                    name: 'Airport Courier',
                    code: 'DP003',
                    x: 15.5,
                    y: 12.3,
                    deliveryArea: 'Airport Zone',
                    priority: 'HIGH'
            ).save(failOnError: true)

            new DeliveryPoint(
                    name: 'Market Lane',
                    code: 'DP004',
                    x: 2.1,
                    y: 1.8,
                    deliveryArea: 'Old Market',
                    priority: 'LOW'
            ).save(failOnError: true)

            new DeliveryPoint(
                    name: 'Tech Park Delivery',
                    code: 'DP005',
                    x: 8.8,
                    y: 9.9,
                    deliveryArea: 'Tech District',
                    priority: 'MEDIUM'
            ).save(failOnError: true)

            new Warehouse(
                    name: 'Central Hub',
                    code: 'WH001',
                    x: 0.0,
                    y: 0.0,
                    maxCapacity: 500,
                    currentLoad: 120
            ).save(failOnError: true)

            new Warehouse(
                    name: 'North Storage',
                    code: 'WH002',
                    x: 12.0,
                    y: 18.0,
                    maxCapacity: 300,
                    currentLoad: 300
            ).save(failOnError: true)

            new Warehouse(
                    name: 'East Depot',
                    code: 'WH003',
                    x: 20.0,
                    y: 5.0,
                    maxCapacity: 200,
                    currentLoad: 80
            ).save(failOnError: true)

            println ">>> BootStrap: seeded ${Location.executeQuery("select count(l) from Location l")[0] as int} locations"
        }
    }

    def destroy = {
    }
}