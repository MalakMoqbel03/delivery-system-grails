package com.ubs.delivery

class BulkLocationController {

    BulkLocationService bulkLocationService

    def index() {
        if (session.role != 'ADMIN') {
            redirect controller: 'auth', action: 'forbidden'
            return
        }
        render view: 'index'  // explicitly tell it which view to render
    }

    def importCsv() {
        if (session.role != 'ADMIN') { render status: 403, text: 'Forbidden'; return }

        def file = request.getFile('file')
        if (!file || file.empty) { render 'Please upload a CSV file.'; return }

        File tempFile = File.createTempFile('bulk_import_', '.csv')
        file.transferTo(tempFile)

        long totalStart = System.currentTimeMillis()
        def result      = bulkLocationService.importCsv(tempFile)
        tempFile.delete()

        render """
            <b>Import complete</b><br>
            Inserted: ${result.inserted}<br>
            Skipped:  ${result.skipped}<br>
            Import time: ${result.timeSec} seconds<br>
            <a href="${createLink(action: 'exportExcel')}">Download decrypted Excel</a>
        """
    }
    def importAndExport() {
        if (session.role != 'ADMIN') {
            render status: 403, text: 'Forbidden'
            return
        }

        def file = request.getFile('file')
        if (!file || file.empty) {
            render 'Please upload a CSV file.'
            return
        }

        File tempFile = File.createTempFile('bulk_import_', '.csv')
        file.transferTo(tempFile)

        def result = bulkLocationService.importCsv(tempFile)
        tempFile.delete()

        File excelFile = bulkLocationService.exportDecryptedExcel()

        response.contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        response.setHeader(
                'Content-Disposition',
                "attachment; filename=decrypted_locations_${result.timeMs}ms.xlsx"
        )

        response.outputStream << excelFile.bytes
        response.outputStream.flush()
        excelFile.delete()
    }

    def exportExcel() {
        if (session.role != 'ADMIN') { render status: 403, text: 'Forbidden'; return }

        long start    = System.currentTimeMillis()
        File excelFile = bulkLocationService.exportDecryptedExcel()
        long elapsed  = System.currentTimeMillis() - start

        log.info("Excel export generated in ${elapsed}ms")

        response.contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        response.setHeader('Content-Disposition', 'attachment; filename=decrypted_locations.xlsx')
        response.outputStream << excelFile.bytes
        response.outputStream.flush()
        excelFile.delete()
    }
}