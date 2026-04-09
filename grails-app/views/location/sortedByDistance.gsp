<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Sorted by Distance</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Locations by Distance</h1>
            <p class="ds-subtitle mb-0">Sorted by straight-line distance from HQ (0, 0) using √(x² + y²).</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header mb-2">
            <h2 class="ds-card-title mb-0">Distance Ranking</h2>
            <div class="ds-card-subtitle">Nearest to farthest from headquarters</div>
        </div>

        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Coordinates</th>
                    <th>Distance</th>
                    <th class="text-end">Actions</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${locationList}" var="loc" status="i">
                    <g:set var="dist" value="${String.format('%.2f', Math.sqrt(loc.x * loc.x + loc.y * loc.y))}"/>
                    <tr>
                        <td class="ds-muted" style="font-size:12px;">${i + 1}</td>
                        <td><span class="ds-pill">${loc.code}</span></td>
                        <td class="ds-td-strong">${loc.name}</td>
                        <td>
                            <g:if test="${loc instanceof com.ubs.delivery.DeliveryPoint}">
                                <span class="ds-pill ds-pill-status-pending">Delivery Point</span>
                            </g:if>
                            <g:elseif test="${loc instanceof com.ubs.delivery.Warehouse}">
                                <span class="ds-pill ds-pill-priority-low">Warehouse</span>
                            </g:elseif>
                            <g:else>
                                <span class="ds-pill">General</span>
                            </g:else>
                        </td>
                        <td class="ds-muted">(${loc.x}, ${loc.y})</td>
                        <td class="fw-bold">${dist} km</td>
                        <td class="text-end">
                            <g:link controller="location" action="insight" id="${loc.id}" class="ds-link me-2">AI Insight</g:link>
                            <g:link controller="location" action="show" id="${loc.id}" class="ds-link me-2">View</g:link>
                            <g:link controller="location" action="edit" id="${loc.id}" class="ds-link">Edit</g:link>
                        </td>
                    </tr>
                </g:each>
                <g:if test="${!locationList}">
                    <tr>
                        <td colspan="7" class="ds-empty">No locations found.</td>
                    </tr>
                </g:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
