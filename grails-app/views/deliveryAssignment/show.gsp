<div class="ds-card mt-4">
    <div class="ds-card-header">
        <div>
            <h2 class="ds-card-title mb-0">Assigned Delivery Points</h2>
            <div class="ds-card-subtitle">Delivery points served by this warehouse</div>
        </div>
        <g:link controller="deliveryAssignment" action="create" class="ds-btn ds-btn-primary">+ Add Assignment</g:link>
    </div>

    <g:if test="${warehouse?.assignments}">
        <div class="table-responsive">
            <table class="table ds-table align-middle mb-0">
                <thead>
                <tr>
                    <th>Delivery Point</th>
                    <th>Status</th>
                    <th>Assigned At</th>
                    <th></th>
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
                            <g:form controller="deliveryAssignment" action="delete" method="DELETE" style="display:inline;">
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
        <p class="ds-empty">No delivery points assigned yet.</p>
    </g:else>
</div>
