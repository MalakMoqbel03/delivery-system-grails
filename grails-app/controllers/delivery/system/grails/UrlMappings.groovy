package delivery.system.grails

class UrlMappings {

    static mappings = {

        "/login" (controller: 'auth') {
            action = [GET: 'login', POST: 'doLogin']
        }
        "/logout" (controller: 'auth', action: 'logout')

        "/$controller/$action?/$id?(.$format)?" {
            constraints {
                // id must be a number if provided — prevents "mainForm" type bugs
                // id matches: [0-9]+
            }
        }

        "/deliveryAssignment"(resources: "deliveryAssignment")
        "/"(controller: "dashboard", action: "index")
        "500"(view: '/error')
        "404"(view: '/notFound')
    }
}
