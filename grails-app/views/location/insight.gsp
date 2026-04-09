<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>AI Insight — ${location?.name}</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">AI Insight</h1>
            <p class="ds-subtitle mb-0">Analysis for <strong>${location?.name}</strong></p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
            <g:link action="history" class="ds-btn ds-btn-secondary">AI History</g:link>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">${location?.name}</h2>
                    <span class="ds-pill">${location?.code}</span>
                </div>
                <table class="ds-detail-table">
                    <tr>
                        <td class="ds-detail-label">Coordinates</td>
                        <td class="ds-detail-value ds-muted">(${location?.x}, ${location?.y})</td>
                    </tr>
                    <tr>
                        <td class="ds-detail-label">Distance from HQ</td>
                        <td class="ds-detail-value fw-bold">${String.format('%.2f', Math.sqrt(location.x * location.x + location.y * location.y))} km</td>
                    </tr>
                    <g:if test="${location instanceof com.ubs.delivery.DeliveryPoint}">
                        <tr>
                            <td class="ds-detail-label">Type</td>
                            <td class="ds-detail-value"><span class="ds-pill ds-pill-status-pending">Delivery Point</span></td>
                        </tr>
                        <tr>
                            <td class="ds-detail-label">Area</td>
                            <td class="ds-detail-value">${location?.deliveryArea}</td>
                        </tr>
                        <tr>
                            <td class="ds-detail-label">Priority</td>
                            <td class="ds-detail-value">
                                <span class="ds-pill ds-pill-priority-${location.priority.toLowerCase()}">${location?.priority}</span>
                            </td>
                        </tr>
                    </g:if>
                    <g:elseif test="${location instanceof com.ubs.delivery.Warehouse}">
                        <tr>
                            <td class="ds-detail-label">Type</td>
                            <td class="ds-detail-value"><span class="ds-pill ds-pill-priority-low">Warehouse</span></td>
                        </tr>
                        <tr>
                            <td class="ds-detail-label">Load</td>
                            <td class="ds-detail-value fw-bold">${location?.currentLoad} / ${location?.maxCapacity} units
                                <g:if test="${!location.hasSpace()}">
                                    <span class="ds-pill ds-pill-priority-high ms-1">FULL</span>
                                </g:if>
                            </td>
                        </tr>
                    </g:elseif>
                </table>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <div>
                        <h2 class="ds-card-title mb-0">AI Analysis</h2>
                        <div class="ds-card-subtitle">Powered by Claude</div>
                    </div>
                    <i class="bi bi-stars" style="font-size:22px;color:#3b82f6;"></i>
                </div>
                <div class="ds-ai-insight-box">
                    <p style="font-size:15px;line-height:1.8;margin:0;">${insight}</p>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
