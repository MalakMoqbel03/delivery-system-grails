package com.ubs.delivery


class AuthInterceptor {

    AuthInterceptor() {
        matchAll()
                .excludes(controller: 'auth')
                .excludes(uri: '/')
                .excludes(uri: '/login')
                .excludes(uri: '/logout')
                .excludes(uri: '/error')
                .excludes(uri: '/notFound')
                .excludes(uri: '/assets/**')
                .excludes(uri: '/api/**')   // already handled by ApiAuthInterceptor
    }

    boolean before() {

        // ── 1. Authentication (401) ───────────────────────────────────────
        if (!session.userId) {
            session.returnUrl = request.forwardURI
            redirect uri: '/login'
            return false
        }

        // ── 2. Authorisation (403) ────────────────────────────────────────
        // session.role is stored as 'ADMIN' or 'USER' (without the ROLE_ prefix)
        String role = session.role ?: 'USER'
        if (role == 'ADMIN') return true

        // Allow authenticated users (any role) to access read-only list/search endpoints
        // that are used to populate the warehouse and location index page tables.
        String requestUri = request.forwardURI ?: '/'
        if (requestUri ==~ '.*/location/(index|search|show/\\d+|warehousesWithSpace).*' ||
                requestUri ==~ '.*/warehouse/(index|show/\\d+).*') {
            return true
        }
        String requiredRole  = resolveRequiredRole(requestUri)

        if (requiredRole == 'ROLE_ADMIN') {
            redirect controller: 'auth', action: 'forbidden'
            return false
        }

        return true
    }

    boolean after()  { true }
    void afterView() {}

    private String resolveRequiredRole(String uri) {
        // Fetch rules ordered: longest/most-specific URLs first, '/**' last
        List<RequestMap> rules = RequestMap.list(sort: 'url', order: 'desc')

        for (RequestMap rule : rules) {
            if (antMatch(rule.url, uri)) {
                return rule.configAttribute
            }
        }
        return 'ROLE_USER'
    }

    private static boolean antMatch(String pattern, String uri) {
        if (pattern == '/**' || pattern == '**') return true
        String regex = pattern
                .replaceAll('\\*\\*', '__DS__')
                .replaceAll('\\*',    '[^/]+')
                .replaceAll('__DS__', '.*')
        uri ==~ /^${regex}(\/.*)?$/
    }
}