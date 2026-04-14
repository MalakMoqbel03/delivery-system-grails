package com.ubs.delivery

/**
 * AuthInterceptor — runs before every request.
 *
 * Two guards:
 *  1. Authentication : redirect to login if no session.
 *  2. Authorisation  : redirect to /forbidden if a USER tries to
 *                      reach any write/admin-only action.
 *
 * Admin-only actions (ADMIN role required):
 *   - Any controller: create, save, edit, update, delete
 *   - WarehouseController        : all actions
 *   - DeliveryPointController    : all actions except index / show
 *   - LocationController         : create, edit, update, delete, highPriority, history, insight, sortedByDistance, warehousesWithSpace
 *   - DeliveryAssignmentController: create, save, delete
 *   - DashboardController        : index  (admins only — users go to userDashboard)
 */
class AuthInterceptor {

    // Write actions that are always admin-only, regardless of controller
    private static final Set<String> ADMIN_WRITE_ACTIONS = [
            'create', 'save', 'edit', 'update', 'delete'
    ] as Set

    // Controllers that are 100% admin-only (every action)
    private static final Set<String> ADMIN_ONLY_CONTROLLERS = [] as Set

    // Per-controller: specific actions that require ADMIN
    private static final Map<String, Set<String>> ADMIN_CONTROLLER_ACTIONS = [
            deliveryPoint      : ['create', 'save', 'edit', 'update', 'delete', 'highPriority', 'checkCode'] as Set,
            deliveryAssignment : ['create', 'save', 'delete'] as Set,
            dashboard          : ['index'] as Set,
            warehouse          : ['create', 'save', 'edit', 'update', 'delete', 'checkCode'] as Set,
            location           : ['create', 'save', 'edit', 'update', 'delete', 'highPriority',
                                  'history', 'insight', 'sortedByDistance', 'warehousesWithSpace', 'index', 'show'] as Set
    ]

    AuthInterceptor() {
        matchAll().excludes(controller: 'auth')
    }

    boolean before() {
        // ── 1. Authentication ────────────────────────────────────────────
        if (!session.userId) {
            session.returnUrl = request.forwardURI
            redirect controller: 'auth', action: 'login'
            return false
        }

        // ── 2. Authorisation ─────────────────────────────────────────────
        String role       = session.role       ?: 'USER'
        String ctrl       = controllerName     ?: ''
        String act        = actionName         ?: 'index'

        if (role != 'ADMIN') {
            boolean blocked = false

            // Whole-controller block
            if (ADMIN_ONLY_CONTROLLERS.contains(ctrl)) {
                blocked = true
            }

            // Generic write actions on any controller
            if (!blocked && ADMIN_WRITE_ACTIONS.contains(act)) {
                blocked = true
            }

            // Specific controller+action combos
            if (!blocked) {
                Set<String> restrictedActions = ADMIN_CONTROLLER_ACTIONS[ctrl]
                if (restrictedActions && restrictedActions.contains(act)) {
                    blocked = true
                }
            }

            if (blocked) {
                redirect controller: 'auth', action: 'forbidden'
                return false
            }
        }

        return true
    }

    boolean after() { true }
    void afterView() {}
}
