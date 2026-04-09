<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <g:set var="entityName" value="${message(code: 'location.label', default: 'Location')}"/>
    <title>Edit Location</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Edit Location</h1>
            <p class="ds-subtitle mb-0">Update location information.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back</g:link>
            <g:link action="show" controller="location" id="${this.location?.id}" class="ds-btn ds-btn-secondary">View</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <g:hasErrors bean="${this.location}">
        <div class="ds-error-box mb-3">
            <ul class="list-unstyled mb-0">
                <g:eachError bean="${this.location}" var="error">
                    <li><i class="bi bi-exclamation-circle me-1"></i><g:message error="${error}"/></li>
                </g:eachError>
            </ul>
        </div>
    </g:hasErrors>

    <div class="row">
        <div class="col-lg-6">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">Location Details</h2>
                </div>
                <g:form action="update" controller="location" id="${this.location?.id}" method="POST">
                    <g:hiddenField name="version" value="${this.location?.version}"/>
                    <fieldset>
                        <div class="ds-form-row">
                            <label class="ds-form-label">Name *</label>
                            <g:textField name="name" value="${this.location?.name}" class="ds-input" required="true"/>
                        </div>
                        <div class="ds-form-row">
                            <label class="ds-form-label">Code *</label>
                            <g:textField name="code" value="${this.location?.code}" class="ds-input" required="true"/>
                        </div>
                        <div class="row g-2">
                            <div class="col-6">
                                <div class="ds-form-row">
                                    <label class="ds-form-label">X Coordinate *</label>
                                    <input type="number" step="0.1" name="x" value="${this.location?.x}" class="ds-input" required/>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="ds-form-row">
                                    <label class="ds-form-label">Y Coordinate *</label>
                                    <input type="number" step="0.1" name="y" value="${this.location?.y}" class="ds-input" required/>
                                </div>
                            </div>
                        </div>
                        <g:if test="${this.location instanceof com.ubs.delivery.Warehouse}">
                            <div class="ds-form-row">
                                <label class="ds-form-label">Max Capacity *</label>
                                <input type="number" name="maxCapacity" value="${((com.ubs.delivery.Warehouse)this.location).maxCapacity}" min="1" class="ds-input" required/>
                            </div>
                            <div class="ds-form-row">
                                <label class="ds-form-label">Current Load *</label>
                                <input type="number" name="currentLoad" value="${((com.ubs.delivery.Warehouse)this.location).currentLoad}" min="0" class="ds-input" required/>
                            </div>
                        </g:if>
                        <g:if test="${this.location instanceof com.ubs.delivery.DeliveryPoint}">
                            <div class="ds-form-row">
                                <label class="ds-form-label">Delivery Area</label>
                                <g:textField name="deliveryArea" value="${((com.ubs.delivery.DeliveryPoint)this.location).deliveryArea}" class="ds-input"/>
                            </div>
                            <div class="ds-form-row">
                                <label class="ds-form-label">Priority</label>
                                <g:select name="priority" from="${['HIGH','MEDIUM','LOW']}"
                                          value="${((com.ubs.delivery.DeliveryPoint)this.location).priority}"
                                          class="ds-input"/>
                            </div>
                        </g:if>
                    </fieldset>
                    <div class="mt-3">
                        <button class="ds-btn ds-btn-primary" type="submit">Save Changes</button>
                    </div>
                </g:form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
