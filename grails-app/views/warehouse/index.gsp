<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>All Warehouses</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>All Warehouses</h1>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<div class="nav-buttons">
    <g:link controller="location" action="index" class="btn btn-secondary">← All Locations</g:link>
    <g:link action="create"                       class="btn btn-primary">+ Add Warehouse</g:link>
</div>

<table id="locationTable">
    <thead>
    <tr>
        <th>Code</th>
        <th>Name</th>
        <th>Current Load</th>
        <th>Max Capacity</th>
        <th>Capacity Bar</th>
        <th>Status</th>
        <th>Coordinates</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${warehouseList}" var="wh">
        <g:set var="rowClass" value="${!wh.hasSpace() ? 'warehouse-full' : ''}"/>
        <g:set var="pct" value="${(int)((wh.currentLoad / wh.maxCapacity) * 100)}"/>
        <tr class="${rowClass}">
            <td><strong>${wh.code}</strong></td>
            <td>${wh.name}</td>
            <td>${wh.currentLoad}</td>
            <td>${wh.maxCapacity}</td>
            <td>
                <div style="background:#eee;border-radius:8px;height:14px;width:100px;display:inline-block;vertical-align:middle;">
                    <div style="background:${pct >= 100 ? '#e67e22' : '#27ae60'};height:14px;border-radius:8px;width:${Math.min(pct,100)}%;"></div>
                </div>
                <span style="font-size:12px;margin-left:4px;">${pct}%</span>
            </td>
            <td>
                <g:if test="${wh.hasSpace()}">
                    <span style="color:#27ae60;font-weight:bold;">Has space</span>
                </g:if>
                <g:else>
                    <span style="color:#e67e22;font-weight:bold;">FULL</span>
                </g:else>
            </td>
            <td>(${wh.x}, ${wh.y})</td>
            <td>
                <g:link controller="location" action="insight" id="${wh.id}" class="btn btn-sm btn-info">AI Insight</g:link>
                <g:link action="show" id="${wh.id}" class="btn btn-sm">View</g:link>
                <g:link action="edit" id="${wh.id}" class="btn btn-sm">Edit</g:link>
                <g:form action="delete" method="POST" style="display:inline">
                    <g:hiddenField name="id" value="${wh.id}"/>
                    <button type="submit" class="btn btn-sm btn-delete"
                            onclick="return confirm('Delete ${wh.name}?')">Delete</button>
                </g:form>
            </td>
        </tr>
    </g:each>
    <g:if test="${!warehouseList}">
        <tr>
            <td colspan="8" style="text-align:center;padding:30px;color:#888;">
                No warehouses yet. <g:link action="create">Add one now.</g:link>
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

<g:if test="${warehouseCount > params.int('max')}">
    <div style="margin-top:16px;">
        <g:paginate total="${warehouseCount ?: 0}"/>
    </div>
</g:if>

</body>
</html>
