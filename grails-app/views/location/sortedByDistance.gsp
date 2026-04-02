<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Sorted by Distance</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Locations Sorted by Distance from HQ</h1>
<p style="color:#666;margin-bottom:16px;">Sorted by straight-line distance from origin (0, 0) using √(x² + y²)</p>
<g:link action="index" class="btn btn-secondary" style="margin-bottom:16px;display:inline-block;">
    ← Back to all locations
</g:link>

<table id="locationTable">
    <thead>
    <tr>
        <th>#</th>
        <th>Code</th>
        <th>Name</th>
        <th>Type</th>
        <th>Coordinates</th>
        <th>Distance from HQ</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${locationList}" var="loc" status="i">
        <g:set var="dist" value="${String.format('%.2f', Math.sqrt(loc.x * loc.x + loc.y * loc.y))}"/>
        <tr>
            <td style="color:#888;font-size:12px;">${i + 1}</td>
            <td><strong>${loc.code}</strong></td>
            <td>${loc.name}</td>
            <td>
                <g:if test="${loc instanceof com.ubs.delivery.DeliveryPoint}">
                    <span class="badge badge-delivery">Delivery Point</span>
                </g:if>
                <g:elseif test="${loc instanceof com.ubs.delivery.Warehouse}">
                    <span class="badge badge-warehouse">Warehouse</span>
                </g:elseif>
                <g:else>
                    <span class="badge badge-general">General</span>
                </g:else>
            </td>
            <td>(${loc.x}, ${loc.y})</td>
            <td><strong>${dist} km</strong></td>
            <td>
                <g:link controller="location" action="insight" id="${loc.id}" class="btn btn-sm btn-info">AI Insight</g:link>
                <g:link controller="location" action="show"    id="${loc.id}" class="btn btn-sm">View</g:link>
                <g:link controller="location" action="edit"    id="${loc.id}" class="btn btn-sm">Edit</g:link>
            </td>
        </tr>
    </g:each>
    <g:if test="${!locationList}">
        <tr>
            <td colspan="7" style="text-align:center;padding:20px;color:#888;">No locations found.</td>
        </tr>
    </g:if>
    </tbody>
</table>

</body>
</html>
