<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Warehouses with Available Space</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Warehouses with Space</h1>
            <p class="ds-subtitle mb-0">Storage facilities that can still accept new loads.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
            <g:link controller="warehouse" action="create" class="ds-btn ds-btn-primary">+ New Warehouse</g:link>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header mb-2">
            <h2 class="ds-card-title mb-0">Available Warehouses</h2>
            <div class="ds-card-subtitle">Sorted by remaining capacity</div>
        </div>

        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0">
                <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Load</th>
                    <th>Capacity Usage</th>
                    <th>Coordinates</th>
                    <th class="text-end">Actions</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${warehouseList}" var="wh">
                    <g:set var="pct" value="${(int)((wh.currentLoad / wh.maxCapacity) * 100)}"/>
                    <tr>
                        <td><span class="ds-pill">${wh.code}</span></td>
                        <td class="ds-td-strong">
                            <g:link controller="warehouse" action="show" id="${wh.id}">${wh.name}</g:link>
                        </td>
                        <td class="ds-muted">${wh.currentLoad} / ${wh.maxCapacity}</td>
                        <td style="min-width:180px;">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label">${pct}% full</span>
                            </div>
                            <div class="ds-progress">
                                <div class="ds-progress-fill ${pct >= 65 ? 'ds-progress-fill-medium' : 'ds-progress-fill-low'}"
                                     style="width:${pct}%;"></div>
                            </div>
                        </td>
                        <td class="ds-muted">(${wh.x}, ${wh.y})</td>
                        <td class="text-end">
                            <g:link controller="location" action="insight" id="${wh.id}" class="ds-link me-2">AI Insight</g:link>
                            <g:link controller="warehouse" action="show" id="${wh.id}" class="ds-link me-2">View</g:link>
                            <g:link controller="warehouse" action="edit" id="${wh.id}" class="ds-link">Edit</g:link>
                        </td>
                    </tr>
                </g:each>
                <g:if test="${!warehouseList}">
                    <tr>
                        <td colspan="6" class="ds-empty">No warehouses with available space found.</td>
                    </tr>
                </g:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
