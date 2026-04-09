<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Delivery Assignments</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Delivery Assignments</h1>
            <p class="ds-subtitle mb-0">Manage warehouse-to-delivery-point assignments and track their status.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="create" class="ds-btn ds-btn-primary">+ New Assignment</g:link>
            <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
        </div>
    </div>

    <div class="row g-4">
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
                    <g:link class="ds-nav-link active" controller="deliveryAssignment" action="index">
                        <span class="ds-nav-dot"></span> Assignments
                    </g:link>
                    <g:link class="ds-nav-link" controller="warehouse" action="index">
                        <span class="ds-nav-dot"></span> Warehouses
                    </g:link>
                    <g:link class="ds-nav-link" controller="deliveryPoint" action="index">
                        <span class="ds-nav-dot"></span> Delivery Points
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="index">
                        <span class="ds-nav-dot"></span> Locations
                    </g:link>
                </div>
            </nav>
        </aside>

        <main class="col-12 col-lg-9">
            <g:if test="${flash.message}">
                <div class="ds-flash mb-3">${flash.message}</div>
            </g:if>

            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">All Assignments</h2>
                        <div class="ds-card-subtitle">Track deliveries from warehouse to destination</div>
                    </div>
                    <div class="ds-search-wrap">
                        <input type="search" id="assignSearch" class="ds-search" placeholder="Search assignments..."/>
                    </div>
                </div>

                <g:if test="${assignmentList}">
                    <div class="table-responsive">
                        <table class="table ds-table align-middle mb-0" id="assignTable">
                            <thead>
                            <tr>
                                <th>Warehouse</th>
                                <th>Delivery Point</th>
                                <th>Status</th>
                                <th>Assigned At</th>
                                <th class="text-end">Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <g:each in="${assignmentList}" var="a">
                                <tr class="ds-activity-row">
                                    <td class="ds-td-strong">
                                        <g:link controller="warehouse" action="show" id="${a.warehouse.id}">${a.warehouse.name}</g:link>
                                    </td>
                                    <td class="ds-td-strong">
                                        <g:link controller="deliveryPoint" action="show" id="${a.deliveryPoint.id}">${a.deliveryPoint.name}</g:link>
                                    </td>
                                    <td>
                                        <span class="ds-pill ds-pill-status-${a.status.toLowerCase()}">${a.status}</span>
                                    </td>
                                    <td class="ds-muted">
                                        <g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd HH:mm"/>
                                    </td>
                                    <td class="text-end">
                                        <g:form controller="deliveryAssignment" action="delete" method="POST" style="display:inline;">
                                            <g:hiddenField name="id" value="${a.id}"/>
                                            <button type="submit" class="ds-btn-danger-inline"
                                                    onclick="return confirm('Delete this assignment?')">Delete</button>
                                        </g:form>
                                    </td>
                                </tr>
                            </g:each>
                            </tbody>
                        </table>
                    </div>
                </g:if>
                <g:else>
                    <p class="ds-empty">No assignments yet. Create one above.</p>
                </g:else>
            </div>
        </main>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const input = document.getElementById('assignSearch');
        const rows = document.querySelectorAll('#assignTable tbody tr');
        input?.addEventListener('input', function () {
            const q = this.value.toLowerCase();
            rows.forEach(r => r.style.display = r.innerText.toLowerCase().includes(q) ? '' : 'none');
        });
    });
</script>
</body>
</html>
