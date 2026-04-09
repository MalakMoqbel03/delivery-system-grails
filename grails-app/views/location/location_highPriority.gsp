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
            <h1 class="ds-title">High Priority Locations</h1>
            <p class="ds-subtitle mb-0">Delivery points requiring immediate attention.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
            <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header mb-2">
            <div>
                <h2 class="ds-card-title mb-0">Urgent Delivery Points</h2>
                <div class="ds-card-subtitle">All HIGH priority destinations</div>
            </div>
        </div>

        <%-- FIX: controller now returns [highPriorityPoints: results] to match this variable name --%>
        <g:if test="${highPriorityPoints && highPriorityPoints.size() > 0}">
            <div class="table-responsive">
                <table class="table ds-table align-middle mb-0">
                    <thead>
                    <tr>
                        <th>Code</th>
                        <th>Name</th>
                        <th>Delivery Area</th>
                        <th>Coordinates</th>
                        <th>Priority</th>
                        <th class="text-end">Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <g:each in="${highPriorityPoints}" var="point">
                        <tr>
                            <td><span class="ds-pill">${point.code}</span></td>
                            <td class="ds-td-strong">${point.name}</td>
                            <td class="ds-muted">${point.deliveryArea}</td>
                            <td class="ds-muted">(${point.x}, ${point.y})</td>
                            <td><span class="ds-pill ds-pill-priority-high">${point.priority}</span></td>
                            <td class="text-end">
                                <g:link controller="deliveryPoint" action="show" id="${point.id}" class="ds-link me-2">View</g:link>
                                <g:link controller="location" action="insight" id="${point.id}" class="ds-link">AI Insight</g:link>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
        </g:if>
        <g:else>
            <p class="ds-empty">No high priority delivery points found.</p>
        </g:else>
    </div>
</div>
</body>
</html>
