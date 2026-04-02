<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>All Locations</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Delivery System — All Locations</h1>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<!-- Phase 6: Navigation buttons — each calls a controller action -->
<div class="nav-buttons">
    <g:link action="highPriority"        class="btn btn-danger">🔴 High Priority</g:link>
    <g:link action="warehousesWithSpace" class="btn btn-success">🟢 Warehouses with Space</g:link>
    <g:link action="sortedByDistance"    class="btn btn-info">📍 Sort by Distance</g:link>
    <g:link action="history"             class="btn btn-secondary">📋 AI History</g:link>
    <g:link controller="deliveryPoint"   action="create" class="btn btn-primary">+ Add Delivery Point</g:link>
    <g:link controller="warehouse"       action="create" class="btn btn-primary">+ Add Warehouse</g:link>
</div>

<!-- Phase 9: JavaScript filter controls -->
<div class="filter-row">
    <input type="text" id="searchBox" placeholder="Filter by name..." onkeyup="filterTable()"/>
    <button id="toggleBtn" onclick="toggleHighPriority()" class="btn btn-danger">
        Show HIGH Priority Only
    </button>
</div>

<!-- Phase 7: Main locations table -->
<table id="locationTable">
    <thead>
    <tr>
        <th>Code</th>
        <th>Name</th>
        <th>Type</th>
        <th>Details</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${locationList}" var="loc">
        <%-- Phase 8: CSS row class based on type and priority --%>
        <g:set var="rowClass" value=""/>
        <g:if test="${loc instanceof com.ubs.delivery.DeliveryPoint && loc.priority == 'HIGH'}">
            <g:set var="rowClass" value="high-priority"/>
        </g:if>
        <g:if test="${loc instanceof com.ubs.delivery.Warehouse && !loc.hasSpace()}">
            <g:set var="rowClass" value="warehouse-full"/>
        </g:if>

        <tr class="${rowClass}" data-priority="${loc instanceof com.ubs.delivery.DeliveryPoint ? loc.priority : ''}" data-name="${loc.name.toLowerCase()}">
            <td><strong>${loc.code}</strong></td>
            <td>${loc.name}</td>

            <td>
                <g:if test="${loc instanceof com.ubs.delivery.DeliveryPoint}">
                    <span class="badge badge-delivery">Delivery Point</span>
                </g:if>
                <g:elseif test="${loc instanceof com.ubs.delivery.Warehouse}">
                    <span class="badge badge-warehouse">Warehouse</span>
                </g:elseif>
                <g:else>
                    <span class="badge badge-general">General</span>
                </g:else>
            </td>

            <td>
                <g:if test="${loc instanceof com.ubs.delivery.DeliveryPoint}">
                    Area: ${loc.deliveryArea} |
                    <span class="priority priority-${loc.priority.toLowerCase()}">${loc.priority}</span>
                </g:if>
                <g:elseif test="${loc instanceof com.ubs.delivery.Warehouse}">
                    ${loc.currentLoad}/${loc.maxCapacity} units
                    <g:if test="${!loc.hasSpace()}"><strong> — FULL</strong></g:if>
                    <g:else> — has space</g:else>
                </g:elseif>
                <g:else>
                    (${loc.x}, ${loc.y})
                </g:else>
            </td>

            <td>
                <%-- Phase 10: AJAX Quick Insight button --%>
                <button class="btn btn-sm btn-info"
                        onclick="getInsightAjax(${loc.id}, this)">Quick Insight</button>
                <div id="insight-${loc.id}" class="insight-inline" style="display:none;"></div>

                <g:link action="insight" id="${loc.id}" class="btn btn-sm">Full Insight</g:link>
                <g:link action="show"    id="${loc.id}" class="btn btn-sm">View</g:link>
                <g:link action="edit"    id="${loc.id}" class="btn btn-sm">Edit</g:link>
                <g:form action="delete" method="POST" style="display:inline">
                    <g:hiddenField name="id" value="${loc.id}"/>
                    <button type="submit" class="btn btn-sm btn-delete"
                            onclick="return confirm('Delete ${loc.name}?')">Delete</button>
                </g:form>
            </td>
        </tr>
    </g:each>
    <g:if test="${!locationList}">
        <tr>
            <td colspan="5" style="text-align:center;padding:30px;color:#888;">
                No locations found. Add a Delivery Point or Warehouse to get started.
            </td>
        </tr>
    </g:if>
    </tbody>
</table>

<script>
    /* Phase 9 — filter by name as user types */
    function filterTable() {
        const query = document.getElementById('searchBox').value.toLowerCase();
        document.querySelectorAll('#locationTable tbody tr[data-name]').forEach(function(row) {
            row.style.display = row.getAttribute('data-name').includes(query) ? '' : 'none';
        });
    }

    /* Phase 9 — toggle HIGH priority only */
    let showingHighOnly = false;
    function toggleHighPriority() {
        showingHighOnly = !showingHighOnly;
        document.querySelectorAll('#locationTable tbody tr[data-name]').forEach(function(row) {
            if (showingHighOnly) {
                row.style.display = row.classList.contains('high-priority') ? '' : 'none';
            } else {
                row.style.display = '';
            }
        });
        document.getElementById('toggleBtn').textContent =
            showingHighOnly ? 'Show All' : 'Show HIGH Priority Only';
    }

    /* Phase 10 — AJAX: fetch insight from backend without page reload */
    function getInsightAjax(locationId, buttonElement) {
        buttonElement.textContent = 'Loading...';
        buttonElement.disabled = true;

        fetch('/location/ajaxInsight/' + locationId)
            .then(function(response) { return response.text(); })
            .then(function(text) {
                const div = document.getElementById('insight-' + locationId);
                div.textContent = text;
                div.style.display = 'block';
                buttonElement.textContent = 'Refresh Insight';
                buttonElement.disabled = false;
            })
            .catch(function() {
                buttonElement.textContent = 'Error — try again';
                buttonElement.disabled = false;
            });
    }
</script>

</body>
</html>
