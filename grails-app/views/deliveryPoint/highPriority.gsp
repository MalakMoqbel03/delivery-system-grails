<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>High Priority Deliveries</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>🔴 High Priority Delivery Points</h1>
<g:link action="index" class="btn btn-secondary" style="margin-bottom:16px;display:inline-block;">
    ← Back to all locations
</g:link>

<table id="locationTable">
    <thead>
    <tr>
        <th>Code</th>
        <th>Name</th>
        <th>Delivery Area</th>
        <th>Priority</th>
        <th>Coordinates</th>
        <th>Distance from HQ</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${deliveryList}" var="dp">
        <g:set var="dist" value="${String.format('%.2f', Math.sqrt(dp.x * dp.x + dp.y * dp.y))}"/>
        <tr class="high-priority">
            <td><strong>${dp.code}</strong></td>
            <td>${dp.name}</td>
            <td>${dp.deliveryArea}</td>
            <td><span class="priority priority-high">${dp.priority}</span></td>
            <td>(${dp.x}, ${dp.y})</td>
            <td><strong>${dist} km</strong></td>
            <td>
                <g:link controller="location" action="insight" id="${dp.id}" class="btn btn-sm btn-info">AI Insight</g:link>
                <g:link controller="deliveryPoint" action="show" id="${dp.id}" class="btn btn-sm">View</g:link>
                <g:link controller="deliveryPoint" action="edit" id="${dp.id}" class="btn btn-sm">Edit</g:link>
            </td>
        </tr>
    </g:each>
    <g:if test="${!deliveryList}">
        <tr>
            <td colspan="7" style="text-align:center;padding:20px;color:#888;">
                No HIGH priority deliveries found.
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

</body>
</html>
