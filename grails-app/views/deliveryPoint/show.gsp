<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Delivery Point — ${deliveryPoint?.name}</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">${deliveryPoint?.name}</h1>
            <p class="ds-subtitle mb-0">Delivery point detail view</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back</g:link>
            <g:link action="edit" id="${deliveryPoint?.id}" class="ds-btn ds-btn-primary">Edit</g:link>
            <g:link controller="location" action="insight" id="${deliveryPoint?.id}" class="ds-btn ds-btn-secondary">AI Insight</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <div class="row g-4">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">Details</h2>
                </div>
                <table class="ds-detail-table">
                    <tr><td class="ds-detail-label">Code</td><td class="ds-detail-value fw-bold">${deliveryPoint?.code}</td></tr>
                    <tr><td class="ds-detail-label">Name</td><td class="ds-detail-value">${deliveryPoint?.name}</td></tr>
                    <tr><td class="ds-detail-label">Delivery Area</td><td class="ds-detail-value">${deliveryPoint?.deliveryArea}</td></tr>
                    <tr>
                        <td class="ds-detail-label">Priority</td>
                        <td class="ds-detail-value">
                            <span class="ds-pill ds-pill-priority-${deliveryPoint?.priority?.toLowerCase()}">${deliveryPoint?.priority}</span>
                        </td>
                    </tr>
                    <tr><td class="ds-detail-label">Coordinates</td><td class="ds-detail-value ds-muted">(${deliveryPoint?.x}, ${deliveryPoint?.y})</td></tr>
                    <tr>
                        <td class="ds-detail-label">Distance from HQ</td>
                        <td class="ds-detail-value fw-bold">${String.format('%.2f', Math.sqrt(deliveryPoint?.x * deliveryPoint?.x + deliveryPoint?.y * deliveryPoint?.y))} km</td>
                    </tr>
                    <%-- Step 7 equivalent: average assignment status weight displayed on the show page --%>
                    <tr>
                        <td class="ds-detail-label">Avg. Status Score</td>
                        <td class="ds-detail-value fw-bold">
                            <g:if test="${avgStatusWeight > 0}">
                                ${String.format('%.2f', avgStatusWeight)}
                                <span class="ds-muted" style="font-size:12px; font-weight:400;">
                                    / 3.00 &nbsp;(1=Pending, 2=In Transit, 3=Delivered)
                                </span>
                            </g:if>
                            <g:else>
                                <span class="ds-muted">No assignments yet</span>
                            </g:else>
                        </td>
                    </tr>
                </table>
                <div class="ds-card-footer mt-3 pt-3">
                    <g:form action="delete" controller="deliveryPoint" method="POST" style="display:inline;">
                        <g:hiddenField name="id" value="${deliveryPoint?.id}"/>
                        <button type="submit" class="ds-btn ds-btn-danger"
                                onclick="return confirm('Are you sure you want to delete ${deliveryPoint?.name}?')">
                            Delete Delivery Point
                        </button>
                    </g:form>
                </div>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Assigned Warehouses</h2>
                        <div class="ds-card-subtitle">Warehouses serving this delivery point</div>
                    </div>
                    <g:link controller="deliveryAssignment" action="create" class="ds-btn ds-btn-primary">+ Add Assignment</g:link>
                </div>

                <g:if test="${deliveryPoint?.assignments}">
                    <div class="table-responsive">
                        <table class="table ds-table align-middle mb-0">
                            <thead>
                            <tr>
                                <th>Warehouse</th>
                                <th>Status</th>
                                <th>Assigned At</th>
                                <th></th>
                            </tr>
                            </thead>
                            <tbody>
                            <g:each in="${deliveryPoint.assignments}" var="a">
                                <tr>
                                    <td class="ds-td-strong">
                                        <g:link controller="warehouse" action="show" id="${a.warehouse.id}">${a.warehouse.name}</g:link>
                                    </td>
                                    <td>
                                        <span class="ds-pill ds-pill-status-${a.status.toLowerCase()}">${a.status}</span>
                                    </td>
                                    <td class="ds-muted"><g:formatDate date="${a.assignedAt}" format="yyyy-MM-dd"/></td>
                                    <td>
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
                    <p class="ds-empty">No warehouses assigned yet.</p>
                </g:else>
            </div>
        </div>
    </div>
</div>
</body>
</html>
