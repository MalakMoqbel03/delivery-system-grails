<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Delivery Assignments — ${warehouse?.name ?: 'Detail'}</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">${warehouse?.name ?: 'Assignments'}</h1>
            <p class="ds-subtitle mb-0">Delivery points served by this warehouse</p>
        </div>
        <div class="ds-header-actions">
            <g:link controller="warehouse" action="index" class="ds-btn ds-btn-secondary">← Back to Warehouses</g:link>
            <g:link controller="deliveryAssignment" action="create" class="ds-btn ds-btn-primary">+ Add Assignment</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3"><i class="bi bi-check-circle-fill me-2"></i>${flash.message}</div>
    </g:if>

    <div class="ds-card mt-4">
        <div class="ds-card-header">
            <div>
                <h2 class="ds-card-title mb-0">Assigned Delivery Points</h2>
                <div class="ds-card-subtitle">Delivery points served by this warehouse</div>
            </div>
        </div>

        <g:if test="${warehouse?.assignments}">
            <div class="table-responsive">
                <table class="table ds-table align-middle mb-0" id="assignShowTable">
                    <thead>
                    <tr>
                        <th>Delivery Point</th>
                        <th>Status</th>
                        <th>Assigned At</th>
                        <th class="text-end no-sort"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <g:each in="${warehouse.assignments}" var="a">
                        <tr>
                            <td class="ds-td-strong">
                                <g:link controller="deliveryPoint" action="show" id="${a.deliveryPoint.id}">
                                    ${a.deliveryPoint.name}
                                </g:link>
                            </td>
                            <td>
                                <span class="ds-pill ds-pill-status-${a.status.toLowerCase()}">${a.status}</span>
                            </td>
                            <td class="ds-muted">
                                <g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd"/>
                            </td>
                            <td class="text-end">
                                <%-- FIX: Use POST (browsers do not support DELETE on forms) --%>
                                <g:form controller="deliveryAssignment" action="delete" method="POST" style="display:inline;">
                                    <g:hiddenField name="id" value="${a.id}"/>
                                    <button type="submit" class="ds-btn-danger-inline"
                                            onclick="return confirm('Remove this assignment?')">Remove</button>
                                </g:form>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
        </g:if>
        <g:else>
            <p class="ds-empty"><i class="bi bi-inbox" style="font-size:24px;display:block;margin-bottom:8px;"></i>No delivery points assigned yet.</p>
        </g:else>
    </div>
</div>

<script>
$(document).ready(function(){
    $('#assignShowTable').DataTable({
        responsive: true,
        pageLength: 15,
        order: [[2, 'desc']],
        columnDefs: [{ orderable: false, targets: 'no-sort' }],
        language: {
            search: '',
            searchPlaceholder: 'Search assignments…',
            info: 'Showing _START_–_END_ of _TOTAL_ assignments',
            emptyTable: 'No assignments yet.'
        }
    });
});
</script>
</body>
</html>
