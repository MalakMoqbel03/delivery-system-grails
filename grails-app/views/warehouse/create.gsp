<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Add Warehouse</title>
    <asset:stylesheet src="delivery.css"/>
</head>
<body>

<h1>Add New Warehouse</h1>

<div class="nav-buttons">
    <g:link action="index" class="btn btn-secondary">← Back to list</g:link>
</div>

<g:if test="${flash.message}">
    <div class="flash-message">${flash.message}</div>
</g:if>

<g:hasErrors bean="${this.warehouse}">
    <ul class="alert alert-danger list-unstyled" role="alert">
        <g:eachError bean="${this.warehouse}" var="error">
            <li><g:message error="${error}"/></li>
        </g:eachError>
    </ul>
</g:hasErrors>

<div style="background:white;padding:24px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:500px;">
    <g:form resource="${this.warehouse}" controller="warehouse" method="POST">
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">Name *</label>
            <g:textField name="name" value="${this.warehouse?.name}" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">Code * (unique)</label>
            <g:textField name="code" value="${this.warehouse?.code}" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">X Coordinate *</label>
            <g:field type="number" step="0.1" name="x" value="${this.warehouse?.x}" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">Y Coordinate *</label>
            <g:field type="number" step="0.1" name="y" value="${this.warehouse?.y}" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <div style="margin-bottom:14px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">Max Capacity * (min: 1)</label>
            <g:field type="number" name="maxCapacity" value="${this.warehouse?.maxCapacity}" min="1" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <div style="margin-bottom:20px;">
            <label style="display:block;margin-bottom:4px;font-weight:bold;">Current Load * (min: 0)</label>
            <g:field type="number" name="currentLoad" value="${this.warehouse?.currentLoad ?: 0}" min="0" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:4px;"/>
        </div>
        <button type="submit" class="btn btn-primary">💾 Create Warehouse</button>
    </g:form>
</div>

</body>
</html>
