package com.ubs.delivery

import grails.gorm.transactions.Transactional
import org.apache.poi.xssf.usermodel.XSSFWorkbook

@Transactional
class BulkLocationService {

    EncryptionService encryptionService
    LocationService   locationService

    Map importCsv(File csvFile) {
        long start = System.currentTimeMillis()

        Set<String> existingCodes = Location.executeQuery(
                'select l.code from Location l'
        ).collect { it?.toString()?.trim()?.toUpperCase()?.replace('_', '') }
                .findAll { it }
                .toSet()

        int inserted = 0
        int skipped  = 0
        int rowNum   = 0

        csvFile.eachLine { line ->
            rowNum++

            if (rowNum == 1) return

            def parts = line.split(',', -1)

            if (parts.size() < 5) {
                skipped++
                return
            }

            String code = parts[0]?.trim()?.toUpperCase()?.replace('_', '')
            String type = parts[1]?.trim()
            String name = parts[2]?.trim()

            Double x = null
            Double y = null

            try {
                x = parts[3]?.trim() ? parts[3].trim().toDouble() : null
                y = parts[4]?.trim() ? parts[4].trim().toDouble() : null
            } catch (Exception ignored) {
                skipped++
                return
            }

            if (!code || !name || x == null || y == null) {
                skipped++
                return
            }

            if (existingCodes.contains(code)) {
                skipped++
                return
            }

            Location loc

            if (type == 'Warehouse') {
                loc = new Warehouse(
                        code        : code,
                        name        : name,
                        maxCapacity : parts.size() > 7 && parts[7]?.trim()
                                ? parts[7].trim().toInteger()
                                : 1,
                        currentLoad : parts.size() > 8 && parts[8]?.trim()
                                ? parts[8].trim().toInteger()
                                : 0
                )
            } else if (type == 'DeliveryPoint') {
                String priorityValue = parts.size() > 6 && parts[6]?.trim()
                        ? parts[6].trim().toUpperCase()
                        : 'LOW'

                if (!(priorityValue in ['LOW', 'MEDIUM', 'HIGH'])) {
                    priorityValue = 'LOW'
                }

                loc = new DeliveryPoint(
                        code         : code,
                        name         : name,
                        deliveryArea : parts.size() > 5 && parts[5]?.trim()
                                ? parts[5].trim()
                                : 'UNKNOWN',
                        priority     : priorityValue
                )
            } else {
                skipped++
                return
            }

            loc.x = encryptionService.encryptCoordinate(x)
            loc.y = encryptionService.encryptCoordinate(y)

            loc.save(failOnError: true, flush: false)

            existingCodes.add(code)
            inserted++

            if (inserted % 500 == 0) {
                Location.withSession { session ->
                    session.flush()
                    session.clear()
                }
            }
        }

        Location.withSession { session ->
            session.flush()
            session.clear()
        }

        long end = System.currentTimeMillis()

        return [
                inserted : inserted,
                skipped  : skipped,
                timeMs   : end - start,
                timeSec  : (end - start) / 1000.0
        ]
    }

    File exportDecryptedExcel() {
        long start = System.currentTimeMillis()

        XSSFWorkbook workbook = new XSSFWorkbook()
        def sheet = workbook.createSheet('Decrypted Locations')

        def header = sheet.createRow(0)

        [
                'Code',
                'Type',
                'Name',
                'X',
                'Y',
                'Delivery Area',
                'Priority',
                'Max Capacity',
                'Current Load'
        ].eachWithIndex { h, i ->
            header.createCell(i).setCellValue(h)
        }

        int rowIdx = 1

        Location.list(sort: 'name', order: 'asc').each { loc ->
            Map data = locationService.decryptToMap(loc)

            def row = sheet.createRow(rowIdx++)

            row.createCell(0).setCellValue(data.code ?: '')
            row.createCell(1).setCellValue(data.type ?: loc.class.simpleName ?: '')
            row.createCell(2).setCellValue(data.name ?: '')

            row.createCell(3).setCellValue(data.x != null ? data.x as double : 0d)
            row.createCell(4).setCellValue(data.y != null ? data.y as double : 0d)

            if (loc instanceof DeliveryPoint) {
                row.createCell(5).setCellValue(loc.deliveryArea ?: '')
                row.createCell(6).setCellValue(loc.priority ?: '')
                row.createCell(7).setCellValue('')
                row.createCell(8).setCellValue('')
            } else if (loc instanceof Warehouse) {
                row.createCell(5).setCellValue('')
                row.createCell(6).setCellValue('')
                row.createCell(7).setCellValue(loc.maxCapacity ?: 0)
                row.createCell(8).setCellValue(loc.currentLoad ?: 0)
            } else {
                row.createCell(5).setCellValue('')
                row.createCell(6).setCellValue('')
                row.createCell(7).setCellValue('')
                row.createCell(8).setCellValue('')
            }
        }

        long end = System.currentTimeMillis()
        long elapsed = end - start

        def summaryRow = sheet.createRow(rowIdx + 1)
        summaryRow.createCell(0).setCellValue('Export time seconds')
        summaryRow.createCell(1).setCellValue(elapsed / 1000.0)
        summaryRow.createCell(2).setCellValue("Total rows: ${rowIdx - 1}")

        File file = File.createTempFile('decrypted_locations_', '.xlsx')

        file.withOutputStream { os ->
            workbook.write(os)
        }

        workbook.close()

        return file
    }
}