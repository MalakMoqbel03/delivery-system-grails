<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Edit Delivery Point</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Edit Delivery Point</h1>
            <p class="ds-subtitle mb-0">Update delivery destination information.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back</g:link>
            <g:link action="show" id="${this.deliveryPoint?.id}" class="ds-btn ds-btn-secondary">View</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <g:hasErrors bean="${this.deliveryPoint}">
        <div class="ds-error-box mb-3">
            <ul class="list-unstyled mb-0">
                <g:eachError bean="${this.deliveryPoint}" var="error">
                    <li><i class="bi bi-exclamation-circle me-1"></i><g:message error="${error}"/></li>
                </g:eachError>
            </ul>
        </div>
    </g:hasErrors>

    <div class="row">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">Delivery Point Details</h2>
                </div>
                <g:form resource="${this.deliveryPoint}" controller="deliveryPoint" method="PUT">
                    <g:hiddenField name="version" value="${this.deliveryPoint?.version}"/>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Name *</label>
                        <g:textField name="name" value="${this.deliveryPoint?.name}" class="ds-input"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Code * (unique)</label>
                        <g:textField name="code" value="${this.deliveryPoint?.code}" class="ds-input"/>
                    </div>
                    <div class="row g-3">
                        <div class="col-6">
                            <div class="ds-form-row">
                                <label class="ds-form-label">X Coordinate *</label>
                                <g:field type="number" step="0.1" name="x" value="${this.deliveryPoint?.x}" class="ds-input"/>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="ds-form-row">
                                <label class="ds-form-label">Y Coordinate *</label>
                                <g:field type="number" step="0.1" name="y" value="${this.deliveryPoint?.y}" class="ds-input"/>
                            </div>
                        </div>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Delivery Area *</label>
                        <g:textField name="deliveryArea" value="${this.deliveryPoint?.deliveryArea}" class="ds-input"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Priority *</label>
                        <g:select name="priority" from="${['LOW','MEDIUM','HIGH']}" value="${this.deliveryPoint?.priority}" class="ds-select"/>
                    </div>
                    <div class="mt-3">
                        <button type="submit" class="ds-btn ds-btn-primary">Save Changes</button>
                    </div>
                </g:form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
