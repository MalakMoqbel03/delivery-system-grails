<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>High Priority Delivery Points</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">High Priority Deliveries</h1>
            <p class="ds-subtitle mb-0">Delivery points that require immediate attention.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back to all</g:link>
            <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header">
            <div>
                <h2 class="ds-card-title mb-0">Urgent Delivery Points</h2>
                <div class="ds-card-subtitle">All HIGH priority destinations</div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0">
                <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Delivery Area</th>
                    <th>Priority</th>
                    <th>Coordinates</th>
                    <th>Distance from HQ</th>
                    <th class="text-end">Actions</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${deliveryList}" var="dp">
                    <g:set var="dist" value="${String.format('%.2f', Math.sqrt(dp.x * dp.x + dp.y * dp.y))}"/>
                    <tr>
                        <td><span class="ds-pill">${dp.code}</span></td>
                        <td class="ds-td-strong">${dp.name}</td>
                        <td class="ds-muted">${dp.deliveryArea}</td>
                        <td><span class="ds-pill ds-pill-priority-high">${dp.priority}</span></td>
                        <td class="ds-muted">(${dp.x}, ${dp.y})</td>
                        <td class="fw-bold">${dist} km</td>
                        <td class="text-end">
                            <g:link controller="location" action="insight" id="${dp.id}" class="ds-link me-2">AI Insight</g:link>
                            <g:link controller="deliveryPoint" action="show" id="${dp.id}" class="ds-link me-2">View</g:link>
                            <g:link controller="deliveryPoint" action="edit" id="${dp.id}" class="ds-link">Edit</g:link>
                        </td>
                    </tr>
                </g:each>
                <g:if test="${!deliveryList}">
                    <tr>
                        <td colspan="7" class="ds-empty">No HIGH priority deliveries found.</td>
                    </tr>
                </g:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
