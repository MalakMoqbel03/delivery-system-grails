<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>All Delivery Points</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>All Delivery Points</h1>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<div class="nav-buttons">
    <g:link controller="location" action="index"  class="btn btn-secondary">← All Locations</g:link>
    <g:link action="create"                        class="btn btn-primary">+ Add Delivery Point</g:link>
</div>

<table id="locationTable">
    <thead>
    <tr>
        <th>Code</th>
        <th>Name</th>
        <th>Delivery Area</th>
        <th>Priority</th>
        <th>Coordinates</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${deliveryPointList}" var="dp">
        <g:set var="rowClass" value="${dp.priority == 'HIGH' ? 'high-priority' : ''}"/>
        <tr class="${rowClass}">
            <td><strong>${dp.code}</strong></td>
            <td>${dp.name}</td>
            <td>${dp.deliveryArea}</td>
            <td><span class="priority priority-${dp.priority.toLowerCase()}">${dp.priority}</span></td>
            <td>(${dp.x}, ${dp.y})</td>
            <td>
                <g:link controller="location" action="insight" id="${dp.id}" class="btn btn-sm btn-info">AI Insight</g:link>
                <g:link action="show" id="${dp.id}" class="btn btn-sm">View</g:link>
                <g:link action="edit" id="${dp.id}" class="btn btn-sm">Edit</g:link>
                <g:form action="delete" method="POST" style="display:inline">
                    <g:hiddenField name="id" value="${dp.id}"/>
                    <button type="submit" class="btn btn-sm btn-delete"
                            onclick="return confirm('Delete ${dp.name}?')">Delete</button>
                </g:form>
            </td>
        </tr>
    </g:each>
    <g:if test="${!deliveryPointList}">
        <tr>
            <td colspan="6" style="text-align:center;padding:30px;color:#888;">
                No delivery points yet. <g:link action="create">Add one now.</g:link>
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

<g:if test="${deliveryPointCount > params.int('max')}">
    <div style="margin-top:16px;">
        <g:paginate total="${deliveryPointCount ?: 0}"/>
    </div>
</g:if>

</body>
</html>
