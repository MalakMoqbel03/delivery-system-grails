package com.ubs.delivery


class AuthInterceptor {

    AuthInterceptor() {
        matchAll()
                .excludes(controller: 'auth')
                .excludes(uri: '/api/health')
                .excludes(uri: '/api/v1/**')
                .excludes(uri: '/api/v2/**')
    }

    boolean before() {

        // ── 1. Authentication (401) ───────────────────────────────────────
        if (!session.userId) {
            session.returnUrl = request.forwardURI
            redirect controller: 'auth', action: 'login'
            return false
        }

        // ── 2. Authorisation (403) ────────────────────────────────────────
        String role = session.role ?: 'ROLE_USER'
        if (role == 'ROLE_ADMIN') return true

        String requestUri    = request.forwardURI ?: '/'
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