<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Dashboard</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body data-context-path="${request.contextPath ?: ''}">
<g:set var="ctx" value="${request.contextPath ?: ''}"/>

<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Delivery Dashboard</h1>
            <p class="ds-subtitle mb-0">Operational overview for warehouses, delivery points, and assignments.</p>
        </div>
        <div class="ds-header-actions">
            <a class="ds-btn ds-btn-primary" href="${ctx}/deliveryAssignment">Assignments</a>
            <a class="ds-btn ds-btn-secondary" href="${ctx}/warehouse">Warehouses</a>
            <a class="ds-btn ds-btn-secondary" href="${ctx}/deliveryPoint">Delivery Points</a>
        </div>
    </div>

    <div class="row g-4">
        <aside class="col-12 col-lg-3">
            <nav class="ds-sidebar" aria-label="Dashboard navigation">
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Overview</div>
                    <g:link class="ds-nav-link" controller="dashboard" action="index" data-nav="dashboard">
                        <span class="ds-nav-dot"></span> Dashboard
                    </g:link>
                </div>

                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Operations</div>
                    <g:link class="ds-nav-link" controller="deliveryAssignment" action="index" data-nav="deliveryAssignment">
                        <span class="ds-nav-dot"></span> Assignments
                    </g:link>
                    <g:link class="ds-nav-link" controller="warehouse" action="index" data-nav="warehouse">
                        <span class="ds-nav-dot"></span> Warehouses
                    </g:link>
                    <g:link class="ds-nav-link" controller="deliveryPoint" action="index" data-nav="deliveryPoint">
                        <span class="ds-nav-dot"></span> Delivery Points
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="index" data-nav="location">
                        <span class="ds-nav-dot"></span> Locations
                    </g:link>
                </div>
            </nav>
        </aside>

        <main class="col-12 col-lg-9">
            <div class="ds-kpi-grid">
                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-boxes"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Warehouses</div>
                        <div class="ds-kpi-value">${warehousesCount}</div>
                        <div class="ds-kpi-meta">${warehousesWithSpaceCount} with available capacity</div>
                    </div>
                </div>

                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-truck"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Delivery Points</div>
                        <div class="ds-kpi-value">${deliveryPointsCount}</div>
                        <div class="ds-kpi-meta">${priorityHigh} HIGH priority</div>
                    </div>
                </div>

                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-list-check"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Active Assignments</div>
                        <div class="ds-kpi-value">${activeAssignments}</div>
                        <div class="ds-kpi-meta">${assignmentCount} total</div>
                    </div>
                </div>

                <g:link controller="location" action="highPriority" class="ds-kpi-card" style="text-decoration:none; display:block; cursor:pointer;">
                    <div class="ds-kpi-icon"><i class="bi bi-flag-fill"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Urgent Need</div>
                        <div class="ds-kpi-value">${highPriorityDeliveriesCount}</div>
                        <div class="ds-kpi-meta">HIGH priority deliveries</div>
                    </div>
                </g:link>
            </div>

            <div class="row g-4 ds-two-col mt-1">
                <section class="col-12 col-lg-6 ds-card">
                    <div class="ds-card-header">
                        <h2 class="ds-card-title mb-0">Priority Distribution</h2>
                        <div class="ds-card-subtitle">Across all delivery points</div>
                    </div>

                    <div class="ds-priority-bars" role="img" aria-label="Priority distribution chart">
                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-high">HIGH</span>
                                <span class="ds-bar-value">${priorityHigh}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-high"
                                     style="width: ${deliveryPointsCount ? ((priorityHigh * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>

                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-medium">MEDIUM</span>
                                <span class="ds-bar-value">${priorityMedium}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-medium"
                                     style="width: ${deliveryPointsCount ? ((priorityMedium * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>

                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-low">LOW</span>
                                <span class="ds-bar-value">${priorityLow}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-low"
                                     style="width: ${deliveryPointsCount ? ((priorityLow * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="col-12 col-lg-6 ds-card">
                    <div class="ds-card-header">
                        <h2 class="ds-card-title mb-0">AI Quick Insight</h2>
                        <div class="ds-card-subtitle">Get an instant recommendation for any location</div>
                    </div>

                    <div class="ds-form-row">
                        <label for="ds-aiLocationSelect" class="ds-form-label">Location</label>
                        <select id="ds-aiLocationSelect" class="ds-select">
                            <option value="">Select...</option>
                            <g:each in="${locationOptions}" var="loc">
                                <option value="${loc.id}">
                                    ${(loc instanceof com.ubs.delivery.DeliveryPoint) ? 'Delivery Point' : 'Warehouse'}: ${loc.name} (${loc.code})
                                </option>
                            </g:each>
                        </select>
                    </div>

                    <div class="ds-form-row">
                        <button id="ds-aiRun" type="button" class="ds-btn ds-btn-primary ds-btn-full">
                            Get insight
                        </button>
                    </div>

                    <div id="ds-aiOutput" class="ds-ai-output" aria-live="polite">
                        Choose a location and click <strong>Get insight</strong>.
                    </div>
                </section>
            </div>

            <section class="ds-card mt-4">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Recent Activity</h2>
                        <div class="ds-card-subtitle">Search and review the latest assignments</div>
                    </div>
                    <div class="ds-search-wrap">
                        <input id="ds-searchAssignments" type="search" class="ds-search" placeholder="Search by warehouse or delivery point..."/>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0">
                        <thead>
                        <tr>
                            <th>Warehouse</th>
                            <th>Delivery Point</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Assigned At</th>
                            <th style="width: 1%;"></th>
                        </tr>
                        </thead>
                        <tbody id="ds-activityTbody">
                        <g:each in="${recentAssignments}" var="a">
                            <tr class="ds-activity-row"
                                data-warehouse="${a.warehouse.name}"
                                data-delivery-point="${a.deliveryPoint.name}"
                                data-priority="${a.deliveryPoint.priority}"
                                data-status="${a.status}">
                                <td class="ds-td-strong">
                                    <g:link controller="warehouse" action="show" id="${a.warehouse.id}">
                                        ${a.warehouse.name}
                                    </g:link>
                                </td>
                                <td class="ds-td-strong">
                                    <g:link controller="deliveryPoint" action="show" id="${a.deliveryPoint.id}">
                                        ${a.deliveryPoint.name}
                                    </g:link>
                                </td>
                                <td>
                                    <span class="ds-pill ds-pill-priority ds-pill-priority-${a.deliveryPoint.priority.toLowerCase()}">${a.deliveryPoint.priority}</span>
                                </td>
                                <td>
                                    <span class="ds-pill ds-pill-status ds-pill-status-${a.status.toLowerCase()}">${a.status}</span>
                                </td>
                                <td class="ds-muted">
                                    <g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd HH:mm"/>
                                </td>
                                <td class="text-end">
                                    <g:link controller="deliveryAssignment" action="index" class="ds-link">
                                        View all
                                    </g:link>
                                </td>
                            </tr>
                        </g:each>

                        <g:if test="${!recentAssignments || recentAssignments.isEmpty()}">
                            <tr>
                                <td colspan="6" class="ds-empty">
                                    No assignments yet. Create one from the Assignments page.
                                </td>
                            </tr>
                        </g:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
</div>

<asset:javascript src="dashboard.js"/>
</body>
</html>

<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Dashboard</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body data-context-path="${request.contextPath ?: ''}">
<g:set var="ctx" value="${request.contextPath ?: ''}"/>

<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Delivery Dashboard</h1>
            <p class="ds-subtitle mb-0">Operational overview for warehouses, delivery points, and assignments.</p>
        </div>
        <div class="ds-header-actions">
            <a class="ds-btn ds-btn-primary" href="${ctx}/deliveryAssignment">Assignments</a>
            <a class="ds-btn ds-btn-secondary" href="${ctx}/warehouse">Warehouses</a>
            <a class="ds-btn ds-btn-secondary" href="${ctx}/deliveryPoint">Delivery Points</a>
        </div>
    </div>

    <div class="row g-4">
        <aside class="col-12 col-lg-3">
            <nav class="ds-sidebar" aria-label="Dashboard navigation">
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Overview</div>
                    <g:link class="ds-nav-link" controller="dashboard" action="index" data-nav="dashboard">
                        <span class="ds-nav-dot"></span> Dashboard
                    </g:link>
                </div>

                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Operations</div>
                    <g:link class="ds-nav-link" controller="deliveryAssignment" action="index" data-nav="deliveryAssignment">
                        <span class="ds-nav-dot"></span> Assignments
                    </g:link>
                    <g:link class="ds-nav-link" controller="warehouse" action="index" data-nav="warehouse">
                        <span class="ds-nav-dot"></span> Warehouses
                    </g:link>
                    <g:link class="ds-nav-link" controller="deliveryPoint" action="index" data-nav="deliveryPoint">
                        <span class="ds-nav-dot"></span> Delivery Points
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="index" data-nav="location">
                        <span class="ds-nav-dot"></span> Locations
                    </g:link>
                </div>
            </nav>
        </aside>

        <main class="col-12 col-lg-9">
            <div class="ds-kpi-grid">
                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-boxes"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Warehouses</div>
                        <div class="ds-kpi-value">${warehousesCount}</div>
                        <div class="ds-kpi-meta">${warehousesWithSpaceCount} with available capacity</div>
                    </div>
                </div>

                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-truck"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Delivery Points</div>
                        <div class="ds-kpi-value">${deliveryPointsCount}</div>
                        <div class="ds-kpi-meta">${priorityHigh} HIGH priority</div>
                    </div>
                </div>

                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-list-check"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Active Assignments</div>
                        <div class="ds-kpi-value">${activeAssignments}</div>
                        <div class="ds-kpi-meta">${assignmentCount} total</div>
                    </div>
                </div>
                <div class="ds-kpi-card">
                    <div class="ds-kpi-icon"><i class="bi bi-flag-fill"></i></div>
                    <div class="ds-kpi-content">
                        <div class="ds-kpi-label">Urgent Need</div>
                        <div class="ds-kpi-value">${highPriorityDeliveriesCount}</div>
                        <div class="ds-kpi-meta">HIGH priority deliveries</div>
                    </div>
                </div>


            </div>

            <div class="row g-4 ds-two-col mt-1">
                <section class="col-12 col-lg-6 ds-card">
                    <div class="ds-card-header">
                        <h2 class="ds-card-title mb-0">Priority Distribution</h2>
                        <div class="ds-card-subtitle">Across all delivery points</div>
                    </div>

                    <div class="ds-priority-bars" role="img" aria-label="Priority distribution chart">
                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-high">HIGH</span>
                                <span class="ds-bar-value">${priorityHigh}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-high"
                                     style="width: ${deliveryPointsCount ? ((priorityHigh * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>

                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-medium">MEDIUM</span>
                                <span class="ds-bar-value">${priorityMedium}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-medium"
                                     style="width: ${deliveryPointsCount ? ((priorityMedium * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>

                        <div class="ds-bar-row">
                            <div class="ds-bar-row-top">
                                <span class="ds-bar-label priority-low">LOW</span>
                                <span class="ds-bar-value">${priorityLow}</span>
                            </div>
                            <div class="ds-progress" aria-hidden="true">
                                <div class="ds-progress-fill ds-progress-fill-low"
                                     style="width: ${deliveryPointsCount ? ((priorityLow * 100) / deliveryPointsCount) : 0}%;"></div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="col-12 col-lg-6 ds-card">
                    <div class="ds-card-header">
                        <h2 class="ds-card-title mb-0">AI Quick Insight</h2>
                        <div class="ds-card-subtitle">Get an instant recommendation for any location</div>
                    </div>

                    <div class="ds-form-row">
                        <label for="ds-aiLocationSelect" class="ds-form-label">Location</label>
                        <select id="ds-aiLocationSelect" class="ds-select">
                            <option value="">Select...</option>
                            <g:each in="${locationOptions}" var="loc">
                                <option value="${loc.id}">
                                    ${(loc instanceof com.ubs.delivery.DeliveryPoint) ? 'Delivery Point' : 'Warehouse'}: ${loc.name} (${loc.code})
                                </option>
                            </g:each>
                        </select>
                    </div>

                    <div class="ds-form-row">
                        <button id="ds-aiRun" type="button" class="ds-btn ds-btn-primary ds-btn-full">
                            Get insight
                        </button>
                    </div>

                    <div id="ds-aiOutput" class="ds-ai-output" aria-live="polite">
                        Choose a location and click <strong>Get insight</strong>.
                    </div>
                </section>
            </div>

            <section class="ds-card mt-4">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Recent Activity</h2>
                        <div class="ds-card-subtitle">Search and review the latest assignments</div>
                    </div>
                    <div class="ds-search-wrap">
                        <input id="ds-searchAssignments" type="search" class="ds-search" placeholder="Search by warehouse or delivery point..."/>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0">
                        <thead>
                        <tr>
                            <th>Warehouse</th>
                            <th>Delivery Point</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Assigned At</th>
                            <th style="width: 1%;"></th>
                        </tr>
                        </thead>
                        <tbody id="ds-activityTbody">
                        <g:each in="${recentAssignments}" var="a">
                            <tr class="ds-activity-row"
                                data-warehouse="${a.warehouse.name}"
                                data-delivery-point="${a.deliveryPoint.name}"
                                data-priority="${a.deliveryPoint.priority}"
                                data-status="${a.status}">
                                <td class="ds-td-strong">
                                    <g:link controller="warehouse" action="show" id="${a.warehouse.id}">
                                        ${a.warehouse.name}
                                    </g:link>
                                </td>
                                <td class="ds-td-strong">
                                    <g:link controller="deliveryPoint" action="show" id="${a.deliveryPoint.id}">
                                        ${a.deliveryPoint.name}
                                    </g:link>
                                </td>
                                <td>
                                    <span class="ds-pill ds-pill-priority ds-pill-priority-${a.deliveryPoint.priority.toLowerCase()}">${a.deliveryPoint.priority}</span>
                                </td>
                                <td>
                                    <span class="ds-pill ds-pill-status ds-pill-status-${a.status.toLowerCase()}">${a.status}</span>
                                </td>
                                <td class="ds-muted">
                                    <g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd HH:mm"/>
                                </td>
                                <td class="text-end">
                                    <g:link controller="deliveryAssignment" action="index" class="ds-link">
                                        View all
                                    </g:link>
                                </td>
                            </tr>
                        </g:each>

                        <g:if test="${!recentAssignments || recentAssignments.isEmpty()}">
                            <tr>
                                <td colspan="6" class="ds-empty">
                                    No assignments yet. Create one from the Assignments page.
                                </td>
                            </tr>
                        </g:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
</div>

<asset:javascript src="dashboard.js"/>
</body>
</html>

