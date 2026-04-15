package delivery.system.grails
class UrlMappings {

    static mappings = {

        "/login"(controller: 'auth')  { action = [GET: 'login', POST: 'doLogin'] }
        "/logout"(controller: 'auth', action: 'logout')
        "/forbidden"(controller: 'auth', action: 'forbidden')

        "/"(controller: "dashboard", action: "index")
        "/my"(controller: 'userDashboard', action: 'index')
        "/my/update/$id"(controller: 'userDashboard', action: 'updateStatus') {
            constraints { id matches: /\d+/ }
        }
        "/deliveryAssignment"(resources: "deliveryAssignment")

        "/api/health"(controller: "apiHealth", action: "index", method: "GET")
        "/api/v1/locations"(controller: 'locationApiV1', namespace: 'api.v1') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/locations/$id"(controller: 'locationApiV1', namespace: 'api.v1') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        // ── API V2 — Locations ──────────────────────────────────────────────
        "/api/v2/locations"(controller: 'locationApiV2', namespace: 'api.v2') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v2/locations/$id"(controller: 'locationApiV2', namespace: 'api.v2') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        "/api/v1/deliveryPoints"(controller: 'apiDeliveryPoint') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/deliveryPoints/$id"(controller: 'apiDeliveryPoint') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        "/api/v1/warehouses"(controller: 'apiWarehouse') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/warehouses/$id"(controller: 'apiWarehouse') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        "/api/v1/deliveryAssignments"(controller: 'apiDeliveryAssignment') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/deliveryAssignments/$id"(controller: 'apiDeliveryAssignment') {
            action = [GET: 'show', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        "500"(controller: 'apiError', action: 'serverError')
        "404"(controller: 'apiError', action: 'notFound')

        "/$controller/$action?/$id?(.$format)?" {
            constraints {}
        }
    }
}