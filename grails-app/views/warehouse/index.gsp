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
            <p class="ds-subtitle mb-0">Smart warehouse overview with capacity, load, and live availability.</p>
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
                        <div class="ds-kpi-value mt-2">${warehouseList?.count { it.currentLoad < it.maxCapacity } ?: 0}</div>
                        <div class="ds-card-subtitle">Warehouses able to receive loads</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="ds-card">
                        <div class="ds-card-title">At Full Capacity</div>
                        <div class="ds-kpi-value mt-2">${warehouseList?.count { it.currentLoad >= it.maxCapacity } ?: 0}</div>
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
                    <div class="ds-search-wrap">
                        <input type="search" id="warehouseSearch" class="ds-search" placeholder="Search warehouses..."/>
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
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody id="warehouseTableBody">
                        <tr><td colspan="6" class="ds-empty">Loading…</td></tr>
                        </tbody>
                    </table>
                </div>

                <g:if test="${warehouseCount > params.int('max')}">
                    <div class="mt-3 px-2">
                        <g:paginate total="${warehouseCount ?: 0}"/>
                    </div>
                </g:if>
            </div>
        </main>
    </div>
</div>

<script>
    (function () {
        var CTX    = '${request.contextPath ?: ""}';
        var isAdmin = ${session.role == 'ADMIN' ? 'true' : 'false'};
        var input  = document.getElementById('warehouseSearch');
        var tbody  = document.getElementById('warehouseTableBody');
        var debounce = null;

        function pctClass(p) {
            return p >= 90 ? 'ds-progress-fill-high' : (p >= 65 ? 'ds-progress-fill-medium' : 'ds-progress-fill-low');
        }

        function renderRows(data) {
            var warehouses = data.filter(function (loc) { return loc.type === 'Warehouse'; });
            if (warehouses.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="ds-empty">No warehouses found.</td></tr>';
                return;
            }
            tbody.innerHTML = warehouses.map(function (wh) {
                var pct = wh.maxCapacity ? Math.round((wh.currentLoad * 100.0) / wh.maxCapacity) : 0;
                var statusPill = wh.currentLoad >= wh.maxCapacity
                    ? '<span class="ds-pill ds-pill-priority-high">FULL</span>'
                    : (pct >= 80
                        ? '<span class="ds-pill ds-pill-priority-medium">Nearly Full</span>'
                        : '<span class="ds-pill ds-pill-priority-low">Available</span>');
                var bar = '<div class="ds-bar-row-top">' +
                    '<span class="ds-bar-label">' + wh.currentLoad + ' / ' + wh.maxCapacity + '</span>' +
                    '<span class="ds-bar-value">' + pct + '%</span></div>' +
                    '<div class="ds-progress"><div class="ds-progress-fill ' + pctClass(pct) + '" style="width:' + Math.min(pct, 100) + '%;"></div></div>';
                var actions = '<a href="' + CTX + '/warehouse/show/' + wh.id + '" class="ds-link me-2">View</a>';
                if (isAdmin) {
                    actions +=
                        '<a href="' + CTX + '/location/insight/' + wh.id + '" class="ds-link me-2">AI Insight</a>' +
                        '<a href="' + CTX + '/warehouse/edit/'   + wh.id + '" class="ds-link me-2">Edit</a>' +
                        '<form action="' + CTX + '/warehouse/delete" method="POST" style="display:inline;">' +
                        '  <input type="hidden" name="id" value="' + wh.id + '"/>' +
                        '  <button type="submit" class="ds-btn-danger-inline" onclick="return confirm(\'Delete ' + wh.name.replace(/'/g, "\\'") + '?\')">Delete</button>' +
                        '</form>';
                }
                return '<tr>' +
                    '<td class="ds-td-strong"><a href="' + CTX + '/warehouse/show/' + wh.id + '">' + wh.name + '</a></td>' +
                    '<td><span class="ds-pill">' + wh.code + '</span></td>' +
                    '<td class="ds-muted">(' + wh.x + ', ' + wh.y + ')</td>' +
                    '<td style="min-width:160px;">' + bar + '</td>' +
                    '<td>' + statusPill + '</td>' +
                    '<td class="text-end">' + actions + '</td>' +
                    '</tr>';
            }).join('');
        }

        fetch(CTX + '/location/search?q=')
            .then(function (r) { return r.json(); })
            .then(renderRows)
            .catch(function () {});

        input.addEventListener('input', function () {
            var q = this.value.trim();
            clearTimeout(debounce);
            debounce = setTimeout(function () {
                fetch(CTX + '/location/search?q=' + encodeURIComponent(q))
                    .then(function (r) { return r.json(); })
                    .then(renderRows)
                    .catch(function () {});
            }, 250);
        });
    })();
</script>
</body>
</html>