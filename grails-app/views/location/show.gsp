<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Location — ${location?.name}</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">${location?.name}</h1>
            <p class="ds-subtitle mb-0">Location detail view</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back</g:link>
            <g:link action="edit" controller="location" id="${location?.id}" class="ds-btn ds-btn-primary">Edit</g:link>
            <g:link action="insight" id="${location?.id}" class="ds-btn ds-btn-secondary">AI Insight</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <div class="row">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">Details</h2>
                </div>
                <table class="ds-detail-table w-100">
                    <tr><td class="ds-detail-label">Name</td><td class="ds-detail-value fw-bold">${location?.name}</td></tr>
                    <tr><td class="ds-detail-label">Code</td><td class="ds-detail-value">${location?.code}</td></tr>
                    <tr><td class="ds-detail-label">X Coordinate</td><td class="ds-detail-value ds-muted">${location?.x}</td></tr>
                    <tr><td class="ds-detail-label">Y Coordinate</td><td class="ds-detail-value ds-muted">${location?.y}</td></tr>
                    <tr>
                        <td class="ds-detail-label">Type</td>
                        <td class="ds-detail-value">
                            <g:if test="${location instanceof com.ubs.delivery.Warehouse}">
                                <span class="ds-pill ds-pill-priority-low">Warehouse</span>
                            </g:if>
                            <g:elseif test="${location instanceof com.ubs.delivery.DeliveryPoint}">
                                <span class="ds-pill ds-pill-status-pending">Delivery Point</span>
                            </g:elseif>
                            <g:else>
                                <span class="ds-pill">General</span>
                            </g:else>
                        </td>
                    </tr>
                    <g:if test="${location instanceof com.ubs.delivery.Warehouse}">
                        <tr><td class="ds-detail-label">Max Capacity</td><td class="ds-detail-value">${((com.ubs.delivery.Warehouse)location).maxCapacity}</td></tr>
                        <tr><td class="ds-detail-label">Current Load</td><td class="ds-detail-value">${((com.ubs.delivery.Warehouse)location).currentLoad}</td></tr>
                    </g:if>
                    <g:if test="${location instanceof com.ubs.delivery.DeliveryPoint}">
                        <tr><td class="ds-detail-label">Delivery Area</td><td class="ds-detail-value">${((com.ubs.delivery.DeliveryPoint)location).deliveryArea}</td></tr>
                        <tr><td class="ds-detail-label">Priority</td><td class="ds-detail-value">
                            <span class="ds-pill ds-pill-priority-${((com.ubs.delivery.DeliveryPoint)location).priority?.toLowerCase()}">${((com.ubs.delivery.DeliveryPoint)location).priority}</span>
                        </td></tr>
                    </g:if>
                    <tr>
                        <td class="ds-detail-label">Distance from HQ</td>
                        <td class="ds-detail-value fw-bold">${location?.x != null && location?.y != null ? String.format('%.2f', Math.sqrt(location.x * location.x + location.y * location.y)) : 'N/A'} km</td>
                    </tr>
                </table>
                <div class="ds-card-footer mt-3 pt-3">
                    <g:form action="delete" controller="location" method="POST">
                        <g:hiddenField name="id" value="${location?.id}"/>
                        <button class="ds-btn ds-btn-danger" type="submit"
                                onclick="return confirm('Are you sure you want to delete this location?')">
                            Delete Location
                        </button>
                    </g:form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
