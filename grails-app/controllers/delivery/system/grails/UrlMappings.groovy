package delivery.system.grails

class UrlMappings {

    static mappings = {

        "/login"     (controller: 'auth') { action = [GET: 'login', POST: 'doLogin'] }
        "/logout"    (controller: 'auth', action: 'logout')
        "/forbidden" (controller: 'auth', action: 'forbidden')

        "/my"              (controller: 'userDashboard', action: 'index')
        "/my/update/$id"   (controller: 'userDashboard', action: 'updateStatus') {
            constraints { id matches: /\d+/ }
        }

        "/deliveryAssignment" (resources: "deliveryAssignment")
        "/" (controller: "dashboard", action: "index")
        "500" (view: '/error')
        "404" (view: '/notFound')
        "/$controller/$action?/$id?(.$format)?" { constraints {} }
    }
}
