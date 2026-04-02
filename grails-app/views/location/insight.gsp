<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>AI Insight — ${location.name}</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>🤖 AI Insight for ${location.name}</h1>

<div style="margin-bottom:16px;">
    <g:link action="index"   class="btn btn-secondary">← Back to all locations</g:link>
    <g:link action="history" class="btn btn-secondary">📋 View AI History</g:link>
</div>

<%-- Location summary card --%>
<div style="background:white;border-radius:8px;padding:16px 24px;margin-bottom:16px;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
    <h2>${location.name} <span style="font-size:14px;color:#888;">(${location.code})</span></h2>
    <p style="margin:4px 0;color:#555;">
        Coordinates: (${location.x}, ${location.y}) |
        Distance from HQ: <strong>${String.format('%.2f', Math.sqrt(location.x * location.x + location.y * location.y))} km</strong>
    </p>
    <g:if test="${location instanceof com.ubs.delivery.DeliveryPoint}">
        <p style="margin:4px 0;">
            Type: <span class="badge badge-delivery">Delivery Point</span> |
            Area: <strong>${location.deliveryArea}</strong> |
            Priority: <span class="priority priority-${location.priority.toLowerCase()}">${location.priority}</span>
        </p>
    </g:if>
    <g:elseif test="${location instanceof com.ubs.delivery.Warehouse}">
        <p style="margin:4px 0;">
            Type: <span class="badge badge-warehouse">Warehouse</span> |
            Load: <strong>${location.currentLoad}/${location.maxCapacity}</strong> units
            <g:if test="${!location.hasSpace()}"> — <span style="color:#e67e22;font-weight:bold;">FULL</span></g:if>
        </p>
    </g:elseif>
</g:if>
</div>

<%-- AI Insight box --%>
<div class="insight-box">
    <h2 style="margin-top:0;font-size:16px;color:#4a90d9;">💡 AI Analysis</h2>
    <p style="font-size:15px;line-height:1.7;margin:0;">${insight}</p>
</div>

</body>
</html>
