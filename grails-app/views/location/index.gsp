<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Locations</title>
    <asset:stylesheet src="dashboard.css"/>
</head>

<body>
<div class="ds-dashboard">

    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Locations</h1>
            <p class="ds-subtitle mb-0">All warehouses and delivery points in the system.</p>
        </div>

        <div class="ds-header-actions">
            <g:if test="${session.role == 'ADMIN'}">
                <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
            </g:if>

            <g:if test="${session.role == 'USER'}">
                <g:link controller="userDashboard" action="index" class="ds-btn ds-btn-secondary">My Deliveries</g:link>
            </g:if>
        </div>
    </div>

    <div class="row g-4">

        <g:if test="${session.role == 'ADMIN'}">
            <aside class="col-12 col-lg-3">
                <nav class="ds-sidebar" aria-label="Navigation">
                    <div class="ds-sidebar-section">
                        <div class="ds-sidebar-label">Overview</div>
                        <g:link class="ds-nav-link" controller="dashboard" action="index">
                            <span class="ds-nav-dot"></span> Dashboard
                        </g:link>
                    </div>

                    <div class="ds-sidebar-section">
                        <div class="ds-sidebar-label">Operations</div>

                        <g:link class="ds-nav-link" controller="warehouse" action="index">
                            <span class="ds-nav-dot"></span> Warehouses
                        </g:link>

                        <g:link class="ds-nav-link" controller="deliveryPoint" action="index">
                            <span class="ds-nav-dot"></span> Delivery Points
                        </g:link>

                        <g:link class="ds-nav-link active" controller="location" action="index">
                            <span class="ds-nav-dot"></span> Locations
                        </g:link>

                        <g:link class="ds-nav-link" controller="deliveryAssignment" action="index">
                            <span class="ds-nav-dot"></span> Assignments
                        </g:link>
                    </div>
                </nav>
            </aside>
        </g:if>

        <main class="${session.role == 'ADMIN' ? 'col-12 col-lg-9' : 'col-12'}">

            <g:if test="${flash.message}">
                <div class="ds-flash mb-3">${flash.message}</div>
            </g:if>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">Total Locations</div>
                        <div class="ds-kpi-value mt-2">${locationCount ?: locationList?.size() ?: 0}</div>
                        <div class="ds-card-subtitle">All registered locations</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">Warehouses</div>
                        <div class="ds-kpi-value mt-2">
                            ${locationList?.count { it.type == 'Warehouse' } ?: 0}
                        </div>
                        <div class="ds-card-subtitle">Storage hubs</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">Delivery Points</div>
                        <div class="ds-kpi-value mt-2">
                            ${locationList?.count { it.type == 'DeliveryPoint' } ?: 0}
                        </div>
                        <div class="ds-card-subtitle">Customer delivery locations</div>
                    </div>
                </div>
            </div>

            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Location Directory</h2>
                        <div class="ds-card-subtitle">All locations with type and coordinates</div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0" id="locationTable">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Code</th>
                            <th>Type</th>
                            <th>Coordinates</th>
                            <th class="text-end no-sort">Actions</th>
                        </tr>
                        </thead>

                        <tbody>
                        <g:if test="${locationList}">
                            <g:each in="${locationList}" var="loc">
                                <tr>
                                    <td>
                                        <span class="ds-td-strong">${loc.name}</span>
                                    </td>

                                    <td>
                                        <span class="ds-pill">${loc.code}</span>
                                    </td>

                                    <td>
                                        <g:if test="${loc.type == 'Warehouse'}">
                                            <span class="ds-pill ds-pill-priority-low">Warehouse</span>
                                        </g:if>
                                        <g:elseif test="${loc.type == 'DeliveryPoint'}">
                                            <span class="ds-pill ds-pill-priority-medium">Delivery Point</span>
                                        </g:elseif>
                                        <g:else>
                                            <span class="ds-pill">${loc.type}</span>
                                        </g:else>
                                    </td>

                                    <td>
                                        <span class="ds-muted">(${loc.x}, ${loc.y})</span>
                                    </td>

                                    <td class="text-end">
                                        <g:link controller="location" action="show" id="${loc.id}" class="ds-link me-2">View</g:link>

                                        <g:if test="${session.role == 'ADMIN'}">
                                            <g:link controller="location" action="insight" id="${loc.id}" class="ds-link me-2">AI Insight</g:link>
                                        </g:if>
                                    </td>
                                </tr>
                            </g:each>
                        </g:if>

                        <g:else>
                            <tr>
                                <td colspan="5" class="ds-empty">No locations found.</td>
                            </tr>
                        </g:else>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<script>
    $(document).ready(function () {
        $('#locationTable').DataTable({
            responsive: true,
            pageLength: 15,
            order: [[0, 'asc']],
            columnDefs: [
                { orderable: false, targets: 'no-sort' }
            ],
            language: {
                search: '',
                searchPlaceholder: 'Search locations…',
                info: 'Showing _START_–_END_ of _TOTAL_ locations',
                emptyTable: 'No locations found.'
            }
        });
    });
</script>

</body>
</html>