<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>AI Query History</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>📋 AI Query History</h1>
<g:link action="index" class="btn btn-secondary" style="margin-bottom:16px;display:inline-block;">
    ← Back to all locations
</g:link>

<g:if test="${logList}">
    <p style="color:#666;margin-bottom:12px;">Showing ${logList.size()} logged AI queries (newest first)</p>
</g:if>

<table id="locationTable">
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
            <td style="color:#888;font-size:12px;">${i + 1}</td>
            <td>${log.locationName}</td>
            <td><strong>${log.locationCode}</strong></td>
            <td><span class="badge badge-general">${log.queryType}</span></td>
            <td style="max-width:400px;font-size:13px;line-height:1.5;">${log.aiResponse}</td>
            <td style="white-space:nowrap;font-size:13px;">
                <g:formatDate date="${log.queriedAt}" format="dd MMM yyyy HH:mm"/>
            </td>
        </tr>
    </g:each>
    <g:if test="${!logList}">
        <tr>
            <td colspan="6" style="text-align:center;padding:30px;color:#888;">
                No AI queries yet. Click "AI Insight" on any location to generate one.
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

</body>
</html>
