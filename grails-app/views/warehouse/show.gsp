<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Warehouse — ${warehouse?.name}</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">${warehouse?.name}</h1>
            <p class="ds-subtitle mb-0">Warehouse detail view</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back</g:link>
            <g:link action="edit" id="${warehouse?.id}" class="ds-btn ds-btn-primary">Edit</g:link>
            <g:link controller="location" action="insight" id="${warehouse?.id}" class="ds-btn ds-btn-secondary">AI Insight</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <div class="row g-4">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header">
                    <h2 class="ds-card-title mb-0">Details</h2>
                </div>
                <g:set var="pct" value="${warehouse && warehouse.maxCapacity ? (int)((warehouse.currentLoad / warehouse.maxCapacity) * 100) : 0}"/>
                <table class="ds-detail-table">
                    <tr><td class="ds-detail-label">Code</td><td class="ds-detail-value fw-bold">${warehouse?.code}</td></tr>
                    <tr><td class="ds-detail-label">Name</td><td class="ds-detail-value">${warehouse?.name}</td></tr>
                    <tr><td class="ds-detail-label">Current Load</td><td class="ds-detail-value">${warehouse?.currentLoad} units</td></tr>
                    <tr><td class="ds-detail-label">Max Capacity</td><td class="ds-detail-value">${warehouse?.maxCapacity} units</td></tr>
                    <tr>
                        <td class="ds-detail-label">Capacity</td>
                        <td class="ds-detail-value">
                            <div class="ds-bar-row-top mb-1">
                                <span class="ds-bar-label">${pct}% used</span>
                            </div>
                            <div class="ds-progress" style="width:200px;">
                                <div class="ds-progress-fill ${pct >= 90 ? 'ds-progress-fill-high' : (pct >= 65 ? 'ds-progress-fill-medium' : 'ds-progress-fill-low')}"
                                     style="width:${Math.min(pct,100)}%;"></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="ds-detail-label">Status</td>
                        <td class="ds-detail-value">
                            <g:if test="${warehouse?.hasSpace()}">
                                <span class="ds-pill ds-pill-priority-low">Has space available</span>
                            </g:if>
                            <g:else>
                                <span class="ds-pill ds-pill-priority-high">FULL</span>
                            </g:else>
                        </td>
                    </tr>
                    <tr>
                        <td class="ds-detail-label">Coordinates</td>
                        <td class="ds-detail-value ds-muted">
                            (${String.format('%.6f', plainX ?: 0.0)},
                            ${String.format('%.6f', plainY ?: 0.0)})
                        </td>
                    </tr>
                </table>

                <div class="ds-card-footer mt-3 pt-3">
                    <g:form action="delete" controller="warehouse" method="POST" style="display:inline;">
                        <g:hiddenField name="id" value="${warehouse?.id}"/>
                        <button type="submit" class="ds-btn ds-btn-danger"
                                onclick="return confirm('Are you sure you want to delete ${warehouse?.name}?')">
                            Delete Warehouse
                        </button>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
