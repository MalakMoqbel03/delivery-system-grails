<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Warehouse — ${warehouse?.name}</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Warehouse: ${warehouse?.name}</h1>

<div class="nav-buttons">
    <g:link action="index" class="btn btn-secondary">← Back to list</g:link>
    <g:link action="edit" id="${warehouse?.id}" class="btn btn-primary">✏️ Edit</g:link>
    <g:link controller="location" action="insight" id="${warehouse?.id}" class="btn btn-info">🤖 AI Insight</g:link>
</div>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<g:set var="pct" value="${warehouse ? (int)((warehouse.currentLoad / warehouse.maxCapacity) * 100) : 0}"/>

<div style="background:white;padding:24px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:500px;margin-top:16px;">
    <table style="width:100%;border-collapse:collapse;">
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;width:140px;">Code</td>
            <td style="padding:10px;font-weight:bold;">${warehouse?.code}</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Name</td>
            <td style="padding:10px;">${warehouse?.name}</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Current Load</td>
            <td style="padding:10px;">${warehouse?.currentLoad} units</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Max Capacity</td>
            <td style="padding:10px;">${warehouse?.maxCapacity} units</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Capacity</td>
            <td style="padding:10px;">
                <div style="background:#eee;border-radius:8px;height:16px;width:200px;display:inline-block;vertical-align:middle;">
                    <div style="background:${pct >= 100 ? '#e67e22' : '#27ae60'};height:16px;border-radius:8px;width:${Math.min(pct,100)}%;"></div>
                </div>
                <span style="margin-left:8px;">${pct}%</span>
            </td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Status</td>
            <td style="padding:10px;">
                <g:if test="${warehouse?.hasSpace()}">
                    <span style="color:#27ae60;font-weight:bold;">✅ Has space available</span>
                </g:if>
                <g:else>
                    <span style="color:#e67e22;font-weight:bold;">⚠️ FULL</span>
                </g:else>
            </td>
        </tr>
        <tr>
            <td style="padding:10px;color:#888;">Coordinates</td>
            <td style="padding:10px;">(${warehouse?.x}, ${warehouse?.y})</td>
        </tr>
    </table>

    <div style="margin-top:20px;padding-top:16px;border-top:1px solid #eee;">
        <g:form resource="${this.warehouse}" controller="warehouse" method="DELETE" style="display:inline;">
            <button type="submit" class="btn btn-delete"
                    onclick="return confirm('Are you sure you want to delete ${warehouse?.name}?')">
                🗑 Delete
            </button>
        </g:form>
    </div>
</div>

</body>
</html>
