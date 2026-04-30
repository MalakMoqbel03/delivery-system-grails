<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>High Priority Delivery Points</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">High Priority Locations</h1>
            <p class="ds-subtitle mb-0">Delivery points requiring immediate attention.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← All Locations</g:link>
            <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
        </div>
    </div>

    <div class="row g-3 mb-3">
        <div class="col-md-4">
            <div class="ds-card">
                <div class="ds-card-title">High Priority Count</div>
                <div class="ds-kpi-value mt-2">${highPriorityPoints?.size() ?: 0}</div>
                <div class="ds-card-subtitle">Requiring immediate attention</div>
            </div>
        </div>
    </div>

    <div class="ds-card">
        <div class="ds-card-header mb-2">
            <div>
                <h2 class="ds-card-title mb-0">Urgent Delivery Points</h2>
                <div class="ds-card-subtitle">All HIGH priority destinations</div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0" id="highPriorityTable">
                <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Delivery Area</th>
                    <th>Priority</th>
                    <th class="text-end no-sort">Actions</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${highPriorityPoints}" var="point">
                    <tr>
                        <td><span class="ds-pill">${point.code}</span></td>
                        <td class="ds-td-strong">${point.name}</td>
                        <td class="ds-muted">${point.deliveryArea}</td>
                        <td><span class="ds-pill ds-pill-priority-high">${point.priority}</span></td>
                        <td class="text-end">
                            <g:link controller="location" action="show" id="${point.id}" class="ds-link me-2">View</g:link>
                            <g:link controller="location" action="insight" id="${point.id}" class="ds-link">AI Insight</g:link>
                        </td>
                    </tr>
                </g:each>
                <g:if test="${!highPriorityPoints || highPriorityPoints.isEmpty()}">
                    <tr><td colspan="5" class="ds-empty">No high priority delivery points found.</td></tr>
                </g:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
$(document).ready(function(){
    $('#highPriorityTable').DataTable({
        responsive: true,
        pageLength: 15,
        order: [[1, 'asc']],
        columnDefs: [{ orderable: false, targets: 'no-sort' }],
        language: {
            search: '',
            searchPlaceholder: 'Search high priority…',
            info: 'Showing _START_–_END_ of _TOTAL_ locations',
            emptyTable: 'No high priority delivery points found.'
        }
    });
});
</script>
</body>
</html>
