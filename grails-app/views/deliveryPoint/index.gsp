<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Delivery Points</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="container-fluid ds-dashboard py-4">
    <div class="ds-header-row">
        <div>
            <div class="ds-title">Delivery Points</div>
            <div class="ds-subtitle">All registered delivery destinations.</div>
        </div>
        <div class="ds-header-actions">
            <g:if test="${session.role == 'ADMIN'}">
                <g:link controller="deliveryPoint" action="create" class="ds-btn ds-btn-primary">+ New Delivery Point</g:link>
                <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
            </g:if>
            <g:if test="${session.role == 'USER'}">
                <g:link controller="userDashboard" action="index" class="ds-btn ds-btn-secondary">My Deliveries</g:link>
            </g:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-3">
            <div class="ds-sidebar">
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Overview</div>
                    <g:if test="${session.role == 'ADMIN'}">
                        <g:link controller="dashboard" action="index" class="ds-nav-link">
                            <span class="ds-nav-dot"></span> Dashboard
                        </g:link>
                    </g:if>
                    <g:if test="${session.role == 'USER'}">
                        <g:link controller="userDashboard" action="index" class="ds-nav-link">
                            <span class="ds-nav-dot"></span> My Deliveries
                        </g:link>
                    </g:if>
                </div>
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Browse</div>
                    <g:link controller="warehouse" action="index" class="ds-nav-link">
                        <span class="ds-nav-dot"></span> Warehouses
                    </g:link>
                    <g:link controller="deliveryPoint" action="index" class="ds-nav-link active">
                        <span class="ds-nav-dot"></span> Delivery Points
                    </g:link>
                    <g:if test="${session.role == 'ADMIN'}">
                        <g:link controller="location" action="index" class="ds-nav-link">
                            <span class="ds-nav-dot"></span> Locations
                        </g:link>
                        <g:link controller="deliveryAssignment" action="index" class="ds-nav-link">
                            <span class="ds-nav-dot"></span> Assignments
                        </g:link>
                    </g:if>
                </div>
            </div>
        </div>

        <div class="col-lg-9">
            <g:if test="${flash.message}">
                <div class="ds-flash mb-3">${flash.message}</div>
            </g:if>
            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <div class="ds-card-title">Delivery Point List</div>
                        <div class="ds-card-subtitle">All registered delivery destinations</div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0" id="dpTable">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Code</th>
                            <th>Area</th>
                            <th>Priority</th>
                            <th>Coordinates</th>
                            <g:if test="${session.role == 'ADMIN'}">
                                <th class="no-sort text-end">Actions</th>
                            </g:if>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${deliveryPointList}" var="entry">
                            <g:set var="deliveryPoint" value="${entry.instance}"/>
                            <tr>
                                <td class="ds-td-strong">
                                    <g:link controller="deliveryPoint" action="show" id="${deliveryPoint.id}">
                                        ${deliveryPoint.name}
                                    </g:link>
                                </td>
                                <td><span class="ds-pill">${deliveryPoint.code}</span></td>
                                <td>${deliveryPoint.deliveryArea}</td>
                                <td>
                                    <span class="ds-pill ds-pill-priority-${deliveryPoint.priority?.toLowerCase()}">
                                        ${deliveryPoint.priority}
                                    </span>
                                </td>
                                <td class="ds-muted">
                                    (${String.format('%.6f', entry.plainX ?: 0.0)},
                                    ${String.format('%.6f', entry.plainY ?: 0.0)})
                                </td>
                                <g:if test="${session.role == 'ADMIN'}">
                                    <td class="text-end">
                                        <g:link controller="deliveryPoint" action="show" id="${deliveryPoint.id}" class="ds-link me-2">View</g:link>
                                        <g:link controller="deliveryPoint" action="edit" id="${deliveryPoint.id}" class="ds-link me-2">Edit</g:link>
                                        <g:form action="delete" controller="deliveryPoint" method="POST" style="display:inline;">
                                            <g:hiddenField name="id" value="${deliveryPoint.id}"/>
                                            <button type="submit" class="ds-btn-danger-inline ds-confirm-delete"
                                                    data-name="${deliveryPoint.name?.replace("'", "\\'")}">Delete</button>
                                        </g:form>
                                    </td>
                                </g:if>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    //<![CDATA[
    $(document).ready(function(){
        $('#dpTable').DataTable({
            responsive: true,
            pageLength: 15,
            order: [[0, 'asc']],
            columnDefs: [
                { orderable: false, targets: 'no-sort' }
            ],
            language: {
                search: '',
                searchPlaceholder: 'Search delivery points…',
                info: 'Showing _START_–_END_ of _TOTAL_ delivery points',
                emptyTable: 'No delivery points found.'
            }
        });

        $(document).on('click', '.ds-confirm-delete', function(e) {
            var name = $(this).data('name') || 'this item';
            if (!confirm('Delete ' + name + '?')) {
                e.preventDefault();
                return false;
            }
        });
    });
    //]]>
</script>
</body>
</html>
