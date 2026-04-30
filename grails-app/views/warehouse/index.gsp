<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Warehouses</title>
    <asset:stylesheet src="dashboard.css"/>
</head>

<body>
<div class="ds-dashboard">

    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Warehouses</h1>
            <p class="ds-subtitle mb-0">Smart warehouse overview with capacity, load, and availability.</p>
        </div>

        <div class="ds-header-actions">
            <g:if test="${session.role == 'ADMIN'}">
                <g:link controller="warehouse" action="create" class="ds-btn ds-btn-primary">+ New Warehouse</g:link>
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

                        <g:link class="ds-nav-link active" controller="warehouse" action="index">
                            <span class="ds-nav-dot"></span> Warehouses
                        </g:link>

                        <g:link class="ds-nav-link" controller="deliveryPoint" action="index">
                            <span class="ds-nav-dot"></span> Delivery Points
                        </g:link>

                        <g:link class="ds-nav-link" controller="location" action="index">
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
                        <div class="ds-card-title">Total Warehouses</div>
                        <div class="ds-kpi-value mt-2">${warehouseCount ?: warehouseList?.size() ?: 0}</div>
                        <div class="ds-card-subtitle">All registered storage hubs</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">Available Space</div>
                        <div class="ds-kpi-value mt-2">
                            ${warehouseList?.count { it.currentLoad < it.maxCapacity } ?: 0}
                        </div>
                        <div class="ds-card-subtitle">Warehouses able to receive loads</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">At Full Capacity</div>
                        <div class="ds-kpi-value mt-2">
                            ${warehouseList?.count { it.currentLoad >= it.maxCapacity } ?: 0}
                        </div>
                        <div class="ds-card-subtitle">Warehouses at maximum load</div>
                    </div>
                </div>
            </div>

            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Warehouse Directory</h2>
                        <div class="ds-card-subtitle">All storage facilities with capacity status</div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0" id="warehouseTable">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Code</th>
                            <th>Coordinates</th>
                            <th>Usage</th>
                            <th>Status</th>
                            <th class="text-end no-sort">Actions</th>
                        </tr>
                        </thead>

                        <tbody>
                        <g:if test="${warehouseList}">
                            <g:each in="${warehouseList}" var="wh">
                                <%
                                    Integer currentLoad = wh.currentLoad ?: 0
                                    Integer maxCapacity = wh.maxCapacity ?: 0
                                    Integer pct = maxCapacity > 0 ? Math.round((currentLoad * 100.0) / maxCapacity) : 0
                                %>

                                <tr>
                                    <td>
                                        <g:link controller="warehouse" action="show" id="${wh.id}" class="ds-td-strong">
                                            ${wh.name}
                                        </g:link>
                                    </td>

                                    <td>
                                        <span class="ds-pill">${wh.code}</span>
                                    </td>

                                    <td>
                                        <span class="ds-muted">(${wh.x}, ${wh.y})</span>
                                    </td>

                                    <td>
                                        <div style="min-width:160px;">
                                            <div class="ds-bar-row-top">
                                                <span class="ds-bar-label">${currentLoad} / ${maxCapacity}</span>
                                                <span class="ds-bar-value">${pct}%</span>
                                            </div>

                                            <div class="ds-progress">
                                                <div class="ds-progress-fill ${pct >= 90 ? 'ds-progress-fill-high' : pct >= 65 ? 'ds-progress-fill-medium' : 'ds-progress-fill-low'}"
                                                     style="width:${Math.min(pct, 100)}%;"></div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <g:if test="${maxCapacity > 0 && currentLoad >= maxCapacity}">
                                            <span class="ds-pill ds-pill-priority-high">FULL</span>
                                        </g:if>
                                        <g:elseif test="${pct >= 80}">
                                            <span class="ds-pill ds-pill-priority-medium">Nearly Full</span>
                                        </g:elseif>
                                        <g:else>
                                            <span class="ds-pill ds-pill-priority-low">Available</span>
                                        </g:else>
                                    </td>

                                    <td class="text-end">
                                        <g:link controller="warehouse" action="show" id="${wh.id}" class="ds-link me-2">View</g:link>

                                        <g:if test="${session.role == 'ADMIN'}">
                                            <g:link controller="location" action="insight" id="${wh.id}" class="ds-link me-2">AI Insight</g:link>
                                            <g:link controller="warehouse" action="edit" id="${wh.id}" class="ds-link me-2">Edit</g:link>

                                            <g:form controller="warehouse" action="delete" method="POST" style="display:inline;">
                                                <g:hiddenField name="id" value="${wh.id}"/>
                                                <button type="submit"
                                                        class="ds-btn-danger-inline"
                                                        onclick="return confirm('Delete ${wh.name}?')">
                                                    Delete
                                                </button>
                                            </g:form>
                                        </g:if>
                                    </td>
                                </tr>
                            </g:each>
                        </g:if>

                        <g:else>
                            <tr>
                                <td colspan="6" class="ds-empty">No warehouses found.</td>
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
        $('#warehouseTable').DataTable({
            responsive: true,
            pageLength: 15,
            order: [[0, 'asc']],
            columnDefs: [
                { orderable: false, targets: 'no-sort' }
            ],
            language: {
                search: '',
                searchPlaceholder: 'Search warehouses…',
                info: 'Showing _START_–_END_ of _TOTAL_ warehouses',
                emptyTable: 'No warehouses found.'
            }
        });
    });
</script>

</body>
</html>