package api.v2

import com.ubs.delivery.ApiResponse
import com.ubs.delivery.ApiRequestLogService
import com.ubs.delivery.ApiResponseService
import grails.converters.JSON


class ApiAdminLogController {

    ApiResponseService    apiResponseService
    ApiRequestLogService  apiRequestLogService

    static namespace = 'api.v2'

    static allowedMethods = [
            index: 'GET'
    ]

    def index() {
        try {
            String  uriFilter    = params.uri
            Integer statusFilter = params.int('status')

            def logs = apiRequestLogService.listLogs(50, uriFilter, statusFilter)

            def data = [
                    items: logs.collect { entry ->
                        [
                                id            : entry.id,
                                method        : entry.method,
                                uri           : entry.uri,
                                clientToken   : entry.clientToken,
                                responseStatus: entry.responseStatus,
                                durationMs    : entry.durationMs,
                                requestedAt   : entry.requestedAt
                        ]
                    },
                    total : logs.size()
            ]

            renderApi(apiResponseService.ok(data))
        } catch (Exception e) {
            log.error("Failed to fetch API request logs", e)
            renderApi(apiResponseService.serverError("Failed to fetch API request logs"))
        }
    }

    private void renderApi(ApiResponse responseObj) {
        response.addHeader('X-API-Version', 'v2')
        render(
                status     : responseObj.statusCode,
                contentType: 'application/json;charset=UTF-8',
                text       : (responseObj.toMap() as JSON).toString()
        )
    }
}