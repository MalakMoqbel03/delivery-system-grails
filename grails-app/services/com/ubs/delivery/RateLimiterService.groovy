package com.ubs.delivery

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList

class RateLimiterService {

    static final int  MAX_REQUESTS = 30
    static final long WINDOW_MS    = 60_000L

    private final Map<String, List<Long>> requestLog = new ConcurrentHashMap<>()

    boolean isAllowed(String token) {
        long now = System.currentTimeMillis()
        requestLog.putIfAbsent(token, new CopyOnWriteArrayList<>())
        List<Long> timestamps = requestLog.get(token)
        timestamps.removeIf { long t -> t < now - WINDOW_MS }

        if (timestamps.size() >= MAX_REQUESTS) {
            return false
        }

        timestamps.add(now)
        return true
    }

    int remaining(String token) {
        List<Long> timestamps = requestLog.get(token)
        if (!timestamps) return MAX_REQUESTS
        long now = System.currentTimeMillis()
        int used = timestamps.count { long t -> t >= now - WINDOW_MS } as int
        return Math.max(0, MAX_REQUESTS - used)
    }
}
