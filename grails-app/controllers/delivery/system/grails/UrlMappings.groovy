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

        // Health (no auth)
        "/api/health"(controller: "apiHealth", action: "index", method: "GET")
        // ── API V1 — Locations ──────────────────────────────────────────────
        "/api/v1/locations"(controller: 'locationApiV1', namespace: 'api.v1') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/locations/$id"(controller: 'locationApiV1', namespace: 'api.v1') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        // ── API V2 — Locations ──────────────────────────────────────────────
        "/api/v2/locations/highPriority"(controller: 'locationApiV2', namespace: 'api.v2', action: 'highPriority', method: 'GET')
        "/api/v2/locations/sortedByDistance"(controller: 'locationApiV2', namespace: 'api.v2', action: 'sortedByDistance', method: 'GET')
        "/api/v2/locations/search"(controller: 'locationApiV2', namespace: 'api.v2', action: 'search', method: 'GET')
        "/api/v2/locations/aiLog"(controller: 'locationApiV2', namespace: 'api.v2', action: 'aiLog', method: 'GET')
        "/api/v2/locations"(controller: 'locationApiV2', namespace: 'api.v2') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v2/locations/$id"(controller: 'locationApiV2', namespace: 'api.v2') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }
        "/api/v2/locations/$id/insight"(controller: 'locationApiV2', namespace: 'api.v2', action: 'insight', method: 'GET') {
            constraints { id matches: /\d+/ }
        }
        // ── API V2 — Admin logs ─────────────────────────────────────────────
        "/api/v2/admin/logs"(controller: 'apiAdminLog', namespace: 'api.v2') {
            action = [GET: 'index']
        }

        // ── API V1 — Delivery Points ────────────────────────────────────────
        "/api/v1/deliveryPoints"(controller: 'apiDeliveryPoint') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/deliveryPoints/$id"(controller: 'apiDeliveryPoint') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        // ── API V1 — Warehouses ─────────────────────────────────────────────
        "/api/v1/warehouses"(controller: 'apiWarehouse') {
            action = [GET: 'index', POST: 'save']
        }
        "/api/v1/warehouses/$id"(controller: 'apiWarehouse') {
            action = [GET: 'show', PUT: 'update', DELETE: 'delete']
            constraints { id matches: /\d+/ }
        }

        // ── API V1 — Delivery Assignments ───────────────────────────────────
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