package com.ubs.delivery

import grails.gorm.transactions.Transactional


@Transactional(readOnly = true)   // no DB writes from this service itself
class EncryptionBenchmarkService {

    // ── In-memory result store (thread-safe append-only list) ─────────────────
    private final List<Map> results = Collections.synchronizedList([])


    private final Set<Integer> warmedUp = Collections.synchronizedSet([] as Set)

    double timeEncryption(int columnCount, Closure encryptionBlock) {
        boolean isWarmup = warmedUp.add(columnCount)   // add() returns true first time only

        long start = System.nanoTime()
        encryptionBlock.call()
        long end = System.nanoTime()

        long   elapsedNs = end - start
        double elapsedMs = elapsedNs / 1_000_000.0

        results.add([
                columnCount : columnCount,
                elapsedMs   : elapsedMs,
                elapsedNs   : elapsedNs,
                warmup      : isWarmup,
                timestamp   : new Date()
        ])

        String tag = isWarmup ? " [WARMUP - excluded from stats]" : ""
        println String.format(
                ">>> [EncryptionBenchmark] %d-column encrypt -> %.4f ms  (%,d ns)%s",
                columnCount, elapsedMs, elapsedNs, tag
        )

        return elapsedMs
    }

    /**
     * Returns all recorded entries (including warm-ups), most-recent first.
     * Each entry: columnCount, elapsedMs, elapsedNs, warmup (boolean), timestamp.
     */
    List<Map> getBenchmarkResults() {
        new ArrayList<>(results).reverse()
    }

    Map getSummary() {
        List<Map> steady = results.findAll { !it.warmup }
        List<Map> warmups = results.findAll { it.warmup }

        Map summary = steady
                .groupBy { it.columnCount }
                .collectEntries { cols, entries ->
                    List<Double> times = entries*.elapsedMs as List<Double>
                    Map warmupEntry    = warmups.find { it.columnCount == cols }
                    [(cols): [
                            count   : times.size(),
                            avgMs   : times.sum() / times.size(),
                            minMs   : times.min(),
                            maxMs   : times.max(),
                            warmupMs: warmupEntry ? warmupEntry.elapsedMs : null
                    ]]
                }

        // Append a direct comparison when both column counts have steady-state data
        if (summary[2] && summary[4] && summary[2].count > 0 && summary[4].count > 0) {
            double ratio = summary[4].avgMs / summary[2].avgMs
            String note  = (summary[4].count < 3 || summary[2].count < 3)
                    ? "WARNING: small sample - run more inserts for a reliable comparison"
                    : "steady-state comparison (warm-up excluded)"
            summary['comparison'] = [
                    overhead: String.format("%.2fx", ratio),
                    note    : note
            ]
        }

        return summary
    }

    /** Clears all stored results and resets warm-up tracking. */
    void reset() {
        results.clear()
        warmedUp.clear()
    }
}