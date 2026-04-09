<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>AI Query History</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">AI Query History</h1>
            <p class="ds-subtitle mb-0">Log of all AI insight requests across all locations.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header mb-2">
            <div>
                <h2 class="ds-card-title mb-0">Query Log</h2>
                <g:if test="${logList}">
                    <div class="ds-card-subtitle">${logList.size()} recorded AI queries — newest first</div>
                </g:if>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Location</th>
                    <th>Code</th>
                    <th>Query Type</th>
                    <th>AI Response</th>
                    <th>When</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${logList}" var="log" status="i">
                    <tr>
                        <td class="ds-muted" style="font-size:12px;">${i + 1}</td>
                        <td class="ds-td-strong">${log.locationName}</td>
                        <td><span class="ds-pill">${log.locationCode}</span></td>
                        <td><span class="ds-pill ds-pill-status-pending">${log.queryType}</span></td>
                        <td style="max-width:360px;font-size:13px;line-height:1.6;">${log.aiResponse}</td>
                        <td class="ds-muted" style="white-space:nowrap;font-size:13px;">
                            <g:formatDate date="${log.queriedAt}" format="dd MMM yyyy HH:mm"/>
                        </td>
                    </tr>
                </g:each>
                <g:if test="${!logList}">
                    <tr>
                        <td colspan="6" class="ds-empty">
                            No AI queries yet. Click "AI Insight" on any location to generate one.
                        </td>
                    </tr>
                </g:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
