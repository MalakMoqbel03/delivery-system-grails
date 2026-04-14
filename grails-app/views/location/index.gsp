<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Locations</title>
    <asset:stylesheet src="dashboard.css"/>
</head>
<body>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Locations</h1>
            <p class="ds-subtitle mb-0">Unified view of all warehouses and delivery points.</p>
        </div>
        <div class="ds-header-actions">
            <g:link controller="location" action="create" class="ds-btn ds-btn-primary">+ New Location</g:link>
            <g:link controller="dashboard" action="index" class="ds-btn ds-btn-secondary">Dashboard</g:link>
        </div>
    </div>

    <div class="row g-4">
        <aside class="col-12 col-lg-3">
            <nav class="ds-sidebar" aria-label="App navigation">
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Overview</div>
                    <g:link class="ds-nav-link" controller="dashboard" action="index">
                        <span class="ds-nav-dot"></span> Dashboard
                    </g:link>
                </div>
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Operations</div>
                    <g:link class="ds-nav-link" controller="deliveryAssignment" action="index">
                        <span class="ds-nav-dot"></span> Assignments
                    </g:link>
                    <g:link class="ds-nav-link" controller="warehouse" action="index">
                        <span class="ds-nav-dot"></span> Warehouses
                    </g:link>
                    <g:link class="ds-nav-link" controller="deliveryPoint" action="index">
                        <span class="ds-nav-dot"></span> Delivery Points
                    </g:link>
                    <g:link class="ds-nav-link active" controller="location" action="index">
                        <span class="ds-nav-dot"></span> Locations
                    </g:link>
                </div>
                <div class="ds-sidebar-section">
                    <div class="ds-sidebar-label">Views</div>
                    <g:link class="ds-nav-link" controller="location" action="sortedByDistance">
                        <span class="ds-nav-dot"></span> By Distance
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="warehousesWithSpace">
                        <span class="ds-nav-dot"></span> With Space
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="highPriority">
                        <span class="ds-nav-dot"></span> High Priority
                    </g:link>
                    <g:link class="ds-nav-link" controller="location" action="history">
                        <span class="ds-nav-dot"></span> AI History
                    </g:link>
                </div>
            </nav>
        </aside>

        <main class="col-12 col-lg-9">

            <g:if test="${flash.message}">
                <div class="ds-flash mb-3">${flash.message}</div>
            </g:if>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <div class="ds-card">
                        <div class="ds-card-title">Total Locations</div>
                        <%-- locationCount comes from LocationController.index() --%>
                        <div class="ds-kpi-value mt-2">${locationCount ?: 0}</div>
                        <div class="ds-card-subtitle">All registered sites</div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="ds-card">
                        <div class="ds-card-title">AI Insight</div>
                        <div class="ds-kpi-value mt-2" style="font-size:20px;">Enabled</div>
                        <div class="ds-card-subtitle">Click any location for analysis</div>
                    </div>
                </div>
            </div>

            <div class="ds-card">
                <div class="ds-card-header">
                    <div>
                        <h2 class="ds-card-title mb-0">Location Directory</h2>
                        <div class="ds-card-subtitle">All warehouses and delivery points</div>
                    </div>
                    <%--
                        Search input is now just a UI filter over already-rendered rows.
                        The real server-side search lives in LocationService.search()
                        and is called by the navbar via /location/search?q=.
                    --%>
                    <div class="ds-search-wrap">
                        <input id="locationSearch" type="search" class="ds-search" placeholder="Filter list…"/>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table ds-table align-middle mb-0" id="locationTable">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Code</th>
                            <th>Coordinates</th>
                            <th>Type</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody id="locationTableBody">
                        <tr><td colspan="5" class="ds-empty">Loading…</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
    (function () {
        var CTX   = '${request.contextPath ?: ""}';
        var input = document.getElementById('locationSearch');
        var tbody = document.getElementById('locationTableBody');
        var debounce = null;

        // Rebuilds the table body from the JSON array returned by LocationService.search()
        function renderRows(data) {
            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" class="ds-empty">No locations found.</td></tr>';
                return;
            }
            tbody.innerHTML = data.map(function (loc) {
                var typePill = loc.type === 'Warehouse'
                    ? '<span class="ds-pill ds-pill-priority-low">Warehouse</span>'
                    : '<span class="ds-pill ds-pill-status-pending">Delivery Point</span>';
                var isAdmin = ${session.role == 'ADMIN' ? 'true' : 'false'};
                var actions =
                    '<a href="' + CTX + '/location/show/' + loc.id + '" class="ds-link me-2">View</a>';
                if (isAdmin) {
                    actions +=
                        '<a href="' + CTX + '/location/insight/' + loc.id + '" class="ds-link me-2">AI Insight</a>' +
                        '<a href="' + CTX + '/location/edit/'    + loc.id + '" class="ds-link me-2">Edit</a>' +
                        '<form action="' + CTX + '/location/delete" method="POST" style="display:inline;">' +
                        '  <input type="hidden" name="id" value="' + loc.id + '"/>' +
                        '  <button type="submit" class="ds-btn-danger-inline" onclick="return confirm(\'Delete ' + loc.name.replace(/'/g,"\\'") + '?\')">Delete</button>' +
                        '</form>';
                }
                return '<tr>' +
                    '<td class="ds-td-strong">' + loc.name + '</td>' +
                    '<td><span class="ds-pill">' + loc.code + '</span></td>' +
                    '<td class="ds-muted">(' + loc.x + ', ' + loc.y + ')</td>' +
                    '<td>' + typePill + '</td>' +
                    '<td class="text-end">' + actions + '</td>' +
                    '</tr>';
            }).join('');
        }

        // On page load fetch all locations (empty q = return everything)
        fetch(CTX + '/location/search?q=')
            .then(function (r) { return r.json(); })
            .then(renderRows)
            .catch(function () {});

        // On keystroke debounce 250ms then fetch filtered results
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
