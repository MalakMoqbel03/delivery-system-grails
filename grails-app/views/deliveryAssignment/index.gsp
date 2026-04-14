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
            <p class="ds-subtitle mb-0">
                <g:if test="${session.role == 'ADMIN'}">
                    Manage warehouse-to-delivery-point assignments and track their status.
                </g:if>
                <g:else>
                    Overview of all delivery assignments.
                </g:else>
            </p>
        </div>
        <div class="ds-header-actions">
            <g:if test="${session.role == 'ADMIN'}">
                <g:link action="create" class="ds-btn ds-btn-primary">+ New Assignment</g:link>
                <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
            </g:if>
            <g:else>
                <a href="${request.contextPath}/my" class="ds-btn ds-btn-secondary">
                    <i class="bi bi-arrow-left"></i> My Deliveries
                </a>
            </g:else>
        </div>
    </div>

    <div class="row g-4">
        <%-- Sidebar — admin only (users have their own nav in main.gsp) --%>
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
        </g:if>

        <main class="${session.role == 'ADMIN' ? 'col-12 col-lg-9' : 'col-12'}">
            <g:if test="${flash.message}">
                <div class="ds-flash mb-3"><i class="bi bi-check-circle-fill me-2"></i>${flash.message}</div>
            </g:if>
            <g:if test="${flash.error}">
                <div class="ds-error-box mb-3"><i class="bi bi-exclamation-triangle-fill me-2"></i>${flash.error}</div>
            </g:if>

            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">All Assignments</h2>
                        <div class="ds-card-subtitle">Track deliveries from warehouse to destination</div>
                    </div>
                    <div class="ds-search-wrap">
                        <input type="search" id="assignSearch" class="ds-search" placeholder="Search…"/>
                    </div>
                </div>

                <g:if test="${assignmentList}">
                    <div class="table-responsive">
                        <table class="table ds-table align-middle mb-0" id="assignTable">
                            <thead>
                            <tr>
                                <th>Warehouse</th>
                                <th>Delivery Point</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Assigned At</th>
                                <%-- Delete column only for admins --%>
                                <g:if test="${session.role == 'ADMIN'}">
                                    <th class="text-end">Actions</th>
                                </g:if>
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
                                        <span class="ds-pill ds-pill-priority-${a.deliveryPoint.priority.toLowerCase()}">${a.deliveryPoint.priority}</span>
                                    </td>
                                    <td>
                                        <span class="ds-pill ds-pill-status-${a.status.toLowerCase()}">${a.status.replace('_',' ')}</span>
                                    </td>
                                    <td class="ds-muted">
                                        <g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd HH:mm"/>
                                    </td>
                                    <g:if test="${session.role == 'ADMIN'}">
                                        <td class="text-end">
                                            <g:form controller="deliveryAssignment" action="delete" method="POST" style="display:inline;">
                                                <g:hiddenField name="id" value="${a.id}"/>
                                                <button type="submit" class="ds-btn-danger-inline"
                                                        onclick="return confirm('Delete this assignment?')">Delete</button>
                                            </g:form>
                                        </td>
                                    </g:if>
                                </tr>
                            </g:each>
                            </tbody>
                        </table>
                    </div>
                </g:if>
                <g:else>
                    <p class="ds-empty"><i class="bi bi-inbox" style="font-size:24px;display:block;margin-bottom:8px;"></i>No assignments yet.</p>
                </g:else>
            </div>
        </main>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function(){
    var input = document.getElementById('assignSearch');
    var rows  = document.querySelectorAll('#assignTable tbody tr');
    if(!input) return;
    input.addEventListener('input', function(){
        var q = this.value.toLowerCase();
        rows.forEach(function(r){ r.style.display = r.innerText.toLowerCase().includes(q) ? '' : 'none'; });
    });
});
</script>
</body>
</html>
