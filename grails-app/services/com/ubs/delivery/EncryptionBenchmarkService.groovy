package com.ubs.delivery

import grails.gorm.transactions.Transactional


@Transactional(readOnly = true)
class EncryptionBenchmarkService {

    private final List<Map> results = Collections.synchronizedList([])

    private final Set<Integer> warmedUp = Collections.synchronizedSet([] as Set)

    double timeEncryption(int columnCount, Closure encryptionBlock) {
        boolean isWarmup = warmedUp.add(columnCount)

        long start = System.nanoTime()
        encryptionBlock.call()
        long end = System.nanoTime()

        long   elapsedNs = end - start
        double elapsedMs = elapsedNs / 1_000_000.0

        results.add([
                columnCount : columnCount,
                encryptMs   : elapsedMs,
                encryptNs   : elapsedNs,
                insertMs    : null,
                insertNs    : null,
                totalMs     : null,
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

    void recordInsert(int columnCount, long insertNs) {
        double insertMs = insertNs / 1_000_000.0

        Map entry = new ArrayList<>(results).reverse().find {
            it.columnCount == columnCount && it.insertMs == null
        }
        if (entry) {
            entry.insertMs = insertMs
            entry.insertNs = insertNs
            entry.totalMs  = entry.encryptMs + insertMs

            String tag = entry.warmup ? " [WARMUP]" : ""
            println String.format(
                    ">>> [EncryptionBenchmark] %d-column insert  -> %.4f ms  (%,d ns)%s",
                    columnCount, insertMs, insertNs, tag
            )
            println String.format(
                    ">>> [EncryptionBenchmark] %d-column total   -> %.4f ms%s",
                    columnCount, entry.totalMs, tag
            )
        }
    }


    List<Map> getBenchmarkResults() {
        new ArrayList<>(results).reverse()
    }

    Map getSummary() {
        List<Map> steady  = results.findAll { !it.warmup }
        List<Map> warmups = results.findAll {  it.warmup }

        Map summary = steady
                .groupBy { it.columnCount }
                .collectEntries { cols, entries ->

                    List<Double> encTimes   = entries*.encryptMs as List<Double>
                    List<Double> insTimes   = entries.findAll { it.insertMs != null }*.insertMs as List<Double>
                    List<Double> totalTimes = entries.findAll { it.totalMs  != null }*.totalMs  as List<Double>
                    Map warmupEntry         = warmups.find { it.columnCount == cols }

                    [(cols): [
                            count      : encTimes.size(),

                            // encrypt-only
                            encAvgMs   : encTimes.sum() / encTimes.size(),
                            encMinMs   : encTimes.min(),
                            encMaxMs   : encTimes.max(),
                            encWarmupMs: warmupEntry ? warmupEntry.encryptMs : 0.0,

                            // DB insert
                            insCount   : insTimes.size(),
                            insAvgMs   : insTimes   ? insTimes.sum()    / insTimes.size()   : 0.0,
                            insMinMs   : insTimes   ? insTimes.min()    : 0.0,
                            insMaxMs   : insTimes   ? insTimes.max()    : 0.0,
                            insWarmupMs: warmupEntry ? (warmupEntry.insertMs ?: 0.0) : 0.0,

                            // total round-trip
                            totalAvgMs : totalTimes ? totalTimes.sum()  / totalTimes.size() : 0.0,
                            totalMinMs : totalTimes ? totalTimes.min()  : 0.0,
                            totalMaxMs : totalTimes ? totalTimes.max()  : 0.0,
                    ]]
                }

        if (summary[2] && summary[4] && summary[2].count > 0 && summary[4].count > 0) {
            double ratio = summary[4].encAvgMs / summary[2].encAvgMs
            String note  = (summary[4].count < 3 || summary[2].count < 3)
                    ? "WARNING: small sample - run more inserts for a reliable comparison"
                    : "steady-state comparison (warm-up excluded)"
            summary['comparison'] = [
                    encOverhead: String.format("%.2fx", ratio),
                    note       : note
            ]
        }

        return summary
    }

    void reset() {
        results.clear()
        warmedUp.clear()
    }
}