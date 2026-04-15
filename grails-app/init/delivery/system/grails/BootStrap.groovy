package delivery.system.grails
import com.ubs.delivery.ApiToken
import java.util.UUID
import com.ubs.delivery.DeliveryPoint
import com.ubs.delivery.Warehouse
import com.ubs.delivery.Location
import com.ubs.delivery.User
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

class BootStrap {

    def init = { servletContext ->

        def encoder = new BCryptPasswordEncoder(10)

        User.withTransaction {
            if (!User.findByUsername('admin')) {
                new User(username: 'admin', password: encoder.encode('admin123'),
                        role: 'ADMIN', enabled: true)
                        .save(failOnError: true, flush: true)
                println ">>> BootStrap: created user 'admin'"
            }

            if (!User.findByUsername('user')) {
                new User(username: 'user', password: encoder.encode('user123'),
                        role: 'USER', enabled: true)
                        .save(failOnError: true, flush: true)
                println ">>> BootStrap: created user 'user'"
            }
        }

        if (Location.count() == 0) {
            Location.withTransaction {
                new DeliveryPoint(name: 'Downtown Drop',     code: 'DP001', x: 3.5,  y: 7.2,  deliveryArea: 'City Centre',    priority: 'HIGH'  ).save(failOnError: true)
                new DeliveryPoint(name: 'Suburb Stop',       code: 'DP002', x: 10.0, y: 4.0,  deliveryArea: 'North Suburbs',  priority: 'MEDIUM').save(failOnError: true)
                new DeliveryPoint(name: 'Airport Courier',   code: 'DP003', x: 15.5, y: 12.3, deliveryArea: 'Airport Zone',   priority: 'HIGH'  ).save(failOnError: true)
                new DeliveryPoint(name: 'Market Lane',       code: 'DP004', x: 2.1,  y: 1.8,  deliveryArea: 'Old Market',     priority: 'LOW'   ).save(failOnError: true)
                new DeliveryPoint(name: 'Tech Park Delivery',code: 'DP005', x: 8.8,  y: 9.9,  deliveryArea: 'Tech District',  priority: 'MEDIUM').save(failOnError: true)

                new Warehouse(name: 'Central Hub',   code: 'WH001', x: 0.0,  y: 0.0,  maxCapacity: 500, currentLoad: 120).save(failOnError: true)
                new Warehouse(name: 'North Storage', code: 'WH002', x: 12.0, y: 18.0, maxCapacity: 300, currentLoad: 300).save(failOnError: true)
                new Warehouse(name: 'East Depot',    code: 'WH003', x: 20.0, y: 5.0,  maxCapacity: 200, currentLoad: 80 ).save(failOnError: true)

                println ">>> BootStrap: seeded ${Location.executeQuery('select count(l) from Location l')[0] as int} locations"
            }
        }

        if (ApiToken.count() == 0) {
            def token1 = UUID.randomUUID().toString()
            def token2 = UUID.randomUUID().toString()

            new ApiToken(
                    token: token1,
                    clientName: "Bruno Client 1",
                    active: true,
                    createdAt: new Date()
            ).save(failOnError: true)

            new ApiToken(
                    token: token2,
                    clientName: "Bruno Client 2",
                    active: true,
                    createdAt: new Date()
            ).save(failOnError: true)

            println "================ API TOKENS ================"
            println "Token 1: ${token1}"
            println "Token 2: ${token2}"
            println "==========================================="
        }
        println "---- EXISTING TOKENS ----"
        ApiToken.list().each {
            println "TOKEN: ${it.token} | ACTIVE: ${it.active}"
        }
        println "-------------------------"

    }

    def destroy = {}
}
