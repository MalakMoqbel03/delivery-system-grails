<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Warehouses with Space</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Warehouses with Available Space</h1>
<g:link action="index" class="btn btn-secondary" style="margin-bottom:16px;display:inline-block;">
    ← Back to all locations
</g:link>

<table id="locationTable">
    <thead>
    <tr>
        <th>Code</th>
        <th>Name</th>
        <th>Current Load</th>
        <th>Max Capacity</th>
        <th>Space Available</th>
        <th>Coordinates</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${warehouseList}" var="wh">
        <g:set var="pct" value="${(int)((wh.currentLoad / wh.maxCapacity) * 100)}"/>
        <tr>
            <td><strong>${wh.code}</strong></td>
            <td>${wh.name}</td>
            <td>${wh.currentLoad}</td>
            <td>${wh.maxCapacity}</td>
            <td>
                <div style="background:#eee;border-radius:8px;height:14px;width:120px;display:inline-block;vertical-align:middle;">
                    <div style="background:#27ae60;height:14px;border-radius:8px;width:${pct}%;"></div>
                </div>
                <span style="font-size:12px;margin-left:6px;">${pct}% full</span>
            </td>
            <td>(${wh.x}, ${wh.y})</td>
            <td>
                <g:link controller="location" action="insight" id="${wh.id}" class="btn btn-sm btn-info">AI Insight</g:link>
                <g:link controller="warehouse" action="show" id="${wh.id}" class="btn btn-sm">View</g:link>
                <g:link controller="warehouse" action="edit" id="${wh.id}" class="btn btn-sm">Edit</g:link>
            </td>
        </tr>
    </g:each>
    <g:if test="${!warehouseList}">
        <tr>
            <td colspan="7" style="text-align:center;padding:20px;color:#888;">
                No warehouses with available space found.
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

</body>
</html>
