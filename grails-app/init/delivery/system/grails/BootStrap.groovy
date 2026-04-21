package delivery.system.grails

import com.ubs.delivery.ApiToken
import com.ubs.delivery.AuthService
import com.ubs.delivery.DeliveryPoint
import com.ubs.delivery.Location
import com.ubs.delivery.LocationService
import com.ubs.delivery.RequestMap
import com.ubs.delivery.User
import com.ubs.delivery.Warehouse
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

import java.util.UUID
class BootStrap {

    AuthService    authService
    LocationService locationService
    def init = { servletContext ->

        def encoder = new BCryptPasswordEncoder(10)
        if (RequestMap.count() == 0) {
            [
                    [url: '/dashboard/**',                 role: 'ROLE_ADMIN'],
                    [url: '/location/create',              role: 'ROLE_ADMIN'],
                    [url: '/location/save',                role: 'ROLE_ADMIN'],
                    [url: '/location/edit/**',             role: 'ROLE_ADMIN'],
                    [url: '/location/update/**',           role: 'ROLE_ADMIN'],
                    [url: '/location/delete/**',           role: 'ROLE_ADMIN'],
                    [url: '/location/highPriority',        role: 'ROLE_ADMIN'],
                    [url: '/location/history/**',          role: 'ROLE_ADMIN'],
                    [url: '/location/insight/**',          role: 'ROLE_ADMIN'],
                    [url: '/location/sortedByDistance',    role: 'ROLE_ADMIN'],
                    [url: '/location/**',                  role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/create',         role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/save',           role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/edit/**',        role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/update/**',      role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/delete/**',      role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/highPriority',   role: 'ROLE_ADMIN'],
                    [url: '/deliveryPoint/checkCode',      role: 'ROLE_ADMIN'],
                    [url: '/warehouse/create',             role: 'ROLE_ADMIN'],
                    [url: '/warehouse/save',               role: 'ROLE_ADMIN'],
                    [url: '/warehouse/edit/**',            role: 'ROLE_ADMIN'],
                    [url: '/warehouse/update/**',          role: 'ROLE_ADMIN'],
                    [url: '/warehouse/delete/**',          role: 'ROLE_ADMIN'],
                    [url: '/warehouse/checkCode',          role: 'ROLE_ADMIN'],
                    [url: '/deliveryAssignment/create',    role: 'ROLE_ADMIN'],
                    [url: '/deliveryAssignment/save',      role: 'ROLE_ADMIN'],
                    [url: '/deliveryAssignment/delete/**', role: 'ROLE_ADMIN'],
                    [url: '/**',                           role: 'ROLE_USER'],
            ].each { rule ->
                new RequestMap(url: rule.url, configAttribute: rule.role).save(failOnError: true)
            }
        }

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
                def dp1 = new DeliveryPoint(name: 'Downtown Drop',      code: 'DP001', deliveryArea: 'City Centre',   priority: 'HIGH'  )
                locationService.saveWithCoords(dp1, 3.5,  7.2)

                def dp2 = new DeliveryPoint(name: 'Suburb Stop',        code: 'DP002', deliveryArea: 'North Suburbs', priority: 'MEDIUM')
                locationService.saveWithCoords(dp2, 10.0, 4.0)

                def dp3 = new DeliveryPoint(name: 'Airport Courier',    code: 'DP003', deliveryArea: 'Airport Zone',  priority: 'HIGH'  )
                locationService.saveWithCoords(dp3, 15.5, 12.3)

                def dp4 = new DeliveryPoint(name: 'Market Lane',        code: 'DP004', deliveryArea: 'Old Market',    priority: 'LOW'   )
                locationService.saveWithCoords(dp4, 2.1,  1.8)

                def dp5 = new DeliveryPoint(name: 'Tech Park Delivery', code: 'DP005', deliveryArea: 'Tech District', priority: 'MEDIUM')
                locationService.saveWithCoords(dp5, 8.8,  9.9)

                def wh1 = new Warehouse(name: 'Central Hub',   code: 'WH001', maxCapacity: 500, currentLoad: 120)
                locationService.saveWithCoords(wh1, 0.0,  0.0)

                def wh2 = new Warehouse(name: 'North Storage', code: 'WH002', maxCapacity: 300, currentLoad: 300)
                locationService.saveWithCoords(wh2, 12.0, 18.0)

                def wh3 = new Warehouse(name: 'East Depot',    code: 'WH003', maxCapacity: 200, currentLoad: 80)
                locationService.saveWithCoords(wh3, 20.0, 5.0)

                println ">>> BootStrap: seeded ${Location.count()} locations (coordinates encrypted)"
            }
        }

         if (ApiToken.count() == 0) {
            def plain1 = UUID.randomUUID().toString()
            def plain2 = UUID.randomUUID().toString()

            authService.saveToken(plain1, 'Bruno Client 1')
            authService.saveToken(plain2, 'Bruno Client 2')

            println "================ API TOKENS ================"
            println "Token 1 (plain, use in Bruno): ${plain1}"
            println "Token 2 (plain, use in Bruno): ${plain2}"
            println "==========================================="
        }

        println "---- EXISTING TOKENS (stored encrypted — showing client names only) ----"
        ApiToken.list().each {
            println "CLIENT: ${it.clientName} | ACTIVE: ${it.active}"
        }
        println "-------------------------------------------------------------------------"
    }

    def destroy = {}
}