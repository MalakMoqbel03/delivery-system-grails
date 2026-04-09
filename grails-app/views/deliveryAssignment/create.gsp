<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>New Delivery Assignment</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">New Assignment</h1>
            <p class="ds-subtitle mb-0">Link a warehouse to a delivery point and set the initial status.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back to list</g:link>
        </div>
    </div>

    <g:if test="${flash.message}">
        <div class="ds-flash mb-3">${flash.message}</div>
    </g:if>

    <div class="row">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-2">
                    <h2 class="ds-card-title mb-0">Assignment Details</h2>
                    <div class="ds-card-subtitle">Select a warehouse, delivery point, and status</div>
                </div>
                <g:form action="save" method="POST">
                    <div class="ds-form-row">
                        <label class="ds-form-label">Warehouse</label>
                        <g:select name="warehouse.id"
                                  from="${warehouses}"
                                  optionKey="id"
                                  optionValue="name"
                                  noSelection="${['': '-- Select Warehouse --']}"
                                  class="ds-select"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Delivery Point</label>
                        <g:select name="deliveryPoint.id"
                                  from="${deliveryPoints}"
                                  optionKey="id"
                                  optionValue="name"
                                  noSelection="${['': '-- Select Delivery Point --']}"
                                  class="ds-select"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Status</label>
                        <g:select name="status"
                                  from="${['PENDING','IN_TRANSIT','DELIVERED']}"
                                  class="ds-select"/>
                    </div>
                    <div class="mt-3">
                        <button type="submit" class="ds-btn ds-btn-primary">Create Assignment</button>
                    </div>
                </g:form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
