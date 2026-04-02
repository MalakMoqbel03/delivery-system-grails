<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Delivery Point — ${deliveryPoint?.name}</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Delivery Point: ${deliveryPoint?.name}</h1>

<div class="nav-buttons">
    <g:link action="index" class="btn btn-secondary">← Back to list</g:link>
    <g:link action="edit" id="${deliveryPoint?.id}" class="btn btn-primary">✏️ Edit</g:link>
    <g:link controller="location" action="insight" id="${deliveryPoint?.id}" class="btn btn-info">🤖 AI Insight</g:link>
</div>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<div style="background:white;padding:24px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:500px;margin-top:16px;">
    <table style="width:100%;border-collapse:collapse;">
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;width:140px;">Code</td>
            <td style="padding:10px;font-weight:bold;">${deliveryPoint?.code}</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Name</td>
            <td style="padding:10px;">${deliveryPoint?.name}</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Delivery Area</td>
            <td style="padding:10px;">${deliveryPoint?.deliveryArea}</td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Priority</td>
            <td style="padding:10px;">
                <span class="priority priority-${deliveryPoint?.priority?.toLowerCase()}">${deliveryPoint?.priority}</span>
            </td>
        </tr>
        <tr style="border-bottom:1px solid #eee;">
            <td style="padding:10px;color:#888;">Coordinates</td>
            <td style="padding:10px;">(${deliveryPoint?.x}, ${deliveryPoint?.y})</td>
        </tr>
        <tr>
            <td style="padding:10px;color:#888;">Distance from HQ</td>
            <td style="padding:10px;">
                <strong>${String.format('%.2f', Math.sqrt(deliveryPoint?.x * deliveryPoint?.x + deliveryPoint?.y * deliveryPoint?.y))} km</strong>
            </td>
        </tr>
    </table>

    <div style="margin-top:20px;padding-top:16px;border-top:1px solid #eee;">
        <g:form resource="${this.deliveryPoint}" controller="deliveryPoint" method="DELETE" style="display:inline;">
            <button type="submit" class="btn btn-delete"
                    onclick="return confirm('Are you sure you want to delete ${deliveryPoint?.name}?')">
                🗑 Delete
            </button>
        </g:form>
    </div>
</div>

</body>
</html>
