package com.ubs.delivery


class AuthInterceptor {

    private static final Set<String> ADMIN_WRITE_ACTIONS = [
            'create', 'save', 'edit', 'update', 'delete'
    ] as Set

    private static final Set<String> ADMIN_ONLY_CONTROLLERS = [] as Set

    private static final Map<String, Set<String>> ADMIN_CONTROLLER_ACTIONS = [
            deliveryPoint      : ['create', 'save', 'edit', 'update', 'delete', 'highPriority', 'checkCode'] as Set,
            deliveryAssignment : ['create', 'save', 'delete'] as Set,
            dashboard          : ['index'] as Set,
            warehouse          : ['create', 'save', 'edit', 'update', 'delete', 'checkCode'] as Set,
            location           : ['create', 'save', 'edit', 'update', 'delete', 'highPriority',
                                  'history', 'insight', 'sortedByDistance', 'warehousesWithSpace', 'index', 'show'] as Set
    ]

    AuthInterceptor() {
        matchAll()
                .excludes(controller: 'auth')
                .excludes(uri: '/api/**')
    }

    boolean before() {
        // ── 1. Authentication ────────────────────────────────────────────
        if (!session.userId) {
            session.returnUrl = request.forwardURI
            redirect controller: 'auth', action: 'login'
            return false
        }

        // ── 2. Authorisation ─────────────────────────────────────────────
        String role = session.role ?: 'USER'
        String ctrl = controllerName ?: ''
        String act  = actionName     ?: 'index'

        if (role != 'ADMIN') {
            boolean blocked = false

            if (ADMIN_ONLY_CONTROLLERS.contains(ctrl)) {
                blocked = true
            }

            if (!blocked && ADMIN_WRITE_ACTIONS.contains(act)) {
                blocked = true
            }

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
