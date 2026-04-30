<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><g:layoutTitle default="Delivery System"/></title>
    <asset:link rel="icon" href="favicon.ico" type="image/x-ico"/>
    <asset:stylesheet src="application.css"/>

    <%-- DataTables CSS --%>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css"/>
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css"/>

    <g:layoutHead/>
    <style>
        /* ── Navbar ── */
        .ds-navbar { background:#fff; border-bottom:1px solid rgba(0,0,0,0.07); box-shadow:0 2px 12px rgba(0,0,0,0.06); position:sticky; top:0; z-index:1000; }
        .ds-navbar-inner { max-width:1280px; margin:0 auto; padding:0 20px; height:60px; display:flex; align-items:center; gap:8px; }
        .ds-nav-brand { display:flex; align-items:center; gap:10px; font-size:17px; font-weight:900; color:#111; text-decoration:none; letter-spacing:-0.02em; flex-shrink:0; margin-right:8px; }
        .ds-nav-brand img { height:56px; width:auto; }
        .ds-nav-brand:hover { color:#2563eb; }
        .ds-nav-links { display:flex; align-items:center; gap:2px; flex:1; }
        .ds-nav-item { display:inline-flex; align-items:center; gap:6px; padding:7px 12px; border-radius:10px; font-size:13px; font-weight:700; color:rgba(0,0,0,0.60); text-decoration:none; transition:background 120ms,color 120ms; white-space:nowrap; }
        .ds-nav-item:hover { background:rgba(59,130,246,0.08); color:rgba(0,0,0,0.88); }
        .ds-nav-item.active { background:rgba(59,130,246,0.12); color:#1d4ed8; }
        .ds-nav-item i { font-size:14px; }
        .ds-nav-search-wrap { position:relative; margin-left:auto; flex-shrink:0; }
        .ds-nav-search { width:220px; padding:7px 12px 7px 34px; border-radius:10px; border:1px solid rgba(0,0,0,0.12); font-size:13px; font-weight:600; background:#f8f9fa; transition:border-color 120ms,box-shadow 120ms,width 200ms; }
        .ds-nav-search:focus { outline:none; border-color:#3b82f6; box-shadow:0 0 0 3px rgba(59,130,246,0.12); width:280px; background:#fff; }
        .ds-nav-search-icon { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:rgba(0,0,0,0.35); font-size:13px; pointer-events:none; }
        #globalSearchResults { position:absolute; top:calc(100% + 6px); right:0; width:340px; background:#fff; border:1px solid rgba(0,0,0,0.10); border-radius:14px; box-shadow:0 12px 40px rgba(0,0,0,0.12); z-index:2000; display:none; overflow:hidden; }
        #globalSearchResults.open { display:block; }
        .gsr-header { font-size:11px; font-weight:800; color:rgba(0,0,0,0.40); text-transform:uppercase; letter-spacing:.05em; padding:10px 14px 6px; }
        .gsr-item { display:flex; align-items:center; gap:10px; padding:9px 14px; text-decoration:none; color:rgba(0,0,0,0.80); font-weight:600; font-size:13px; transition:background 80ms; cursor:pointer; }
        .gsr-item:hover { background:rgba(59,130,246,0.06); }
        .gsr-badge { font-size:10px; font-weight:900; padding:2px 7px; border-radius:999px; background:rgba(59,130,246,0.10); color:#2563eb; flex-shrink:0; }
        .gsr-badge.dp { background:rgba(16,185,129,0.10); color:#059669; }
        .gsr-coords { margin-left:auto; font-size:11px; color:rgba(0,0,0,0.40); font-weight:700; }
        .gsr-empty { padding:16px 14px; color:rgba(0,0,0,0.40); font-weight:700; font-size:13px; text-align:center; }
        .ds-nav-user { display:flex; align-items:center; gap:8px; margin-left:12px; flex-shrink:0; }
        .ds-nav-username { font-size:13px; font-weight:800; color:rgba(0,0,0,0.65); background:rgba(59,130,246,0.08); border-radius:999px; padding:4px 12px; }
        .ds-nav-username i { margin-right:4px; color:#3b82f6; }
        .ds-nav-logout { font-size:12px; font-weight:800; color:#dc2626; text-decoration:none; padding:4px 10px; border-radius:999px; border:1.5px solid rgba(220,38,38,0.25); transition:background 120ms; }
        .ds-nav-logout:hover { background:rgba(220,38,38,0.08); }
        .ds-nav-toggle { display:none; background:none; border:1px solid rgba(0,0,0,0.12); border-radius:8px; padding:6px 10px; margin-left:auto; cursor:pointer; color:rgba(0,0,0,0.65); }
        @media(max-width:768px){
            .ds-nav-links{display:none;flex-direction:column;gap:4px;}
            .ds-nav-links.open{display:flex;position:absolute;top:60px;left:0;right:0;background:#fff;border-bottom:1px solid rgba(0,0,0,0.07);padding:10px 16px 14px;box-shadow:0 8px 24px rgba(0,0,0,0.08);z-index:999;}
            .ds-nav-toggle{display:flex;}
            .ds-nav-search-wrap{display:none;}
        }

        /* ── DataTables custom styling ── */
        .dataTables_wrapper .dataTables_filter input {
            border: 1.5px solid rgba(0,0,0,0.12);
            border-radius: 10px;
            padding: 6px 12px;
            font-size: 13px;
            font-weight: 600;
            margin-left: 6px;
            transition: border-color 120ms, box-shadow 120ms;
        }
        .dataTables_wrapper .dataTables_filter input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
        }
        .dataTables_wrapper .dataTables_length select {
            border: 1.5px solid rgba(0,0,0,0.12);
            border-radius: 8px;
            padding: 4px 8px;
            font-size: 13px;
            font-weight: 600;
        }
        .dataTables_wrapper .dataTables_info {
            font-size: 13px;
            font-weight: 600;
            color: rgba(0,0,0,0.45);
            padding-top: 12px;
        }
        .dataTables_wrapper .dataTables_paginate {
            padding-top: 10px;
        }
        .dataTables_wrapper .dataTables_paginate .paginate_button {
            border-radius: 8px !important;
            font-size: 13px !important;
            font-weight: 700 !important;
        }
        .dataTables_wrapper .dataTables_paginate .paginate_button.current,
        .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
            background: #2563eb !important;
            color: #fff !important;
            border-color: #2563eb !important;
        }
        table.dataTable thead th {
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: rgba(0,0,0,0.50);
            border-bottom: 2px solid rgba(0,0,0,0.08) !important;
        }
        table.dataTable thead th.sorting:after,
        table.dataTable thead th.sorting_asc:after,
        table.dataTable thead th.sorting_desc:after {
            opacity: 0.5;
        }
        .dataTables_wrapper .dt-buttons { margin-bottom: 8px; }
    </style>
</head>
<body>
<nav class="ds-navbar">
    <div class="ds-navbar-inner">
        <a class="ds-nav-brand" href="${request.contextPath}/dashboard">
            <asset:image src="delivery-logo.svg" alt="Logo"/>
        </a>

        <div class="ds-nav-links" id="navLinks">
            <%-- ADMIN navigation --%>
            <g:if test="${session.role == 'ADMIN'}">
                <a href="${request.contextPath}/dashboard"          class="ds-nav-item" data-nav="dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a>
                <a href="${request.contextPath}/warehouse"          class="ds-nav-item" data-nav="warehouse"><i class="bi bi-boxes"></i> Warehouses</a>
                <a href="${request.contextPath}/deliveryPoint"      class="ds-nav-item" data-nav="deliveryPoint"><i class="bi bi-truck"></i> Delivery Points</a>
                <a href="${request.contextPath}/location"           class="ds-nav-item" data-nav="location"><i class="bi bi-pin-map"></i> Locations</a>
                <a href="${request.contextPath}/deliveryAssignment" class="ds-nav-item" data-nav="deliveryAssignment"><i class="bi bi-list-check"></i> Assignments</a>
            </g:if>

            <%-- USER navigation --%>
            <g:if test="${session.role == 'USER'}">
                <a href="${request.contextPath}/my"           class="ds-nav-item" data-nav="userDashboard"><i class="bi bi-grid-1x2"></i> My Deliveries</a>
                <a href="${request.contextPath}/warehouse"    class="ds-nav-item" data-nav="warehouse"><i class="bi bi-boxes"></i> Warehouses</a>
                <a href="${request.contextPath}/deliveryPoint" class="ds-nav-item" data-nav="deliveryPoint"><i class="bi bi-truck"></i> Delivery Points</a>
            </g:if>
        </div>

        <%-- Global search — ADMIN only --%>
        <g:if test="${session.role == 'ADMIN'}">
            <div class="ds-nav-search-wrap">
                <i class="bi bi-search ds-nav-search-icon"></i>
                <input id="globalSearch" type="search" class="ds-nav-search" placeholder="Search locations…" autocomplete="off"/>
                <div id="globalSearchResults"></div>
            </div>
        </g:if>

        <g:if test="${session.username}">
            <div class="ds-nav-user">
                <span class="ds-nav-username">
                    <i class="bi bi-person-fill"></i>${session.username}
                    <g:if test="${session.role == 'ADMIN'}">
                        &nbsp;<span style="font-size:10px;color:#f59e0b;">★ ADMIN</span>
                    </g:if>
                </span>
                <a href="${request.contextPath}/logout" class="ds-nav-logout">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </g:if>

        <button class="ds-nav-toggle" id="navToggle" aria-label="Toggle menu">
            <i class="bi bi-list" style="font-size:18px;"></i>
        </button>
    </div>
</nav>

<div class="bg-body-tertiary">
    <div class="container-lg py-4">
        <g:layoutBody/>
    </div>
</div>

<footer class="border-top py-4" role="contentinfo">
    <div class="container-lg">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div class="fw-bold" style="color:rgba(0,0,0,0.55);font-size:14px;">Delivery System</div>
            <div style="color:rgba(0,0,0,0.38);font-size:13px;">Operational Dashboard</div>
        </div>
    </div>
</footer>

<div id="spinner" class="position-fixed top-0 end-0 p-2" style="display:none;z-index:9999;">
    <div class="spinner-border spinner-border-sm text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
</div>

<asset:javascript src="application.js"/>

<%-- jQuery + DataTables JS (must come after Bootstrap) --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap5.min.js"></script>

<script>
(function(){
    var path = window.location.pathname;
    document.querySelectorAll('.ds-nav-item[data-nav]').forEach(function(el){
        if (path.indexOf('/' + el.getAttribute('data-nav')) !== -1) el.classList.add('active');
    });

    var toggle = document.getElementById('navToggle');
    var links  = document.getElementById('navLinks');
    if (toggle && links) toggle.addEventListener('click', function(){ links.classList.toggle('open'); });

    /* Global search */
    var searchInput = document.getElementById('globalSearch');
    var resultsBox  = document.getElementById('globalSearchResults');
    if (!searchInput) return;

    var CTX = '${request.contextPath ?: ""}';
    var debounceTimer = null;

    function closeResults(){ resultsBox.classList.remove('open'); }
    function showResults(html){ resultsBox.innerHTML = html; resultsBox.classList.add('open'); }

    searchInput.addEventListener('input', function(){
        var q = this.value.trim();
        if (q.length < 1) { closeResults(); return; }
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function(){
            fetch(CTX + '/location/search?q=' + encodeURIComponent(q))
                .then(function(r){ return r.json(); })
                .then(function(data){
                    if (!data || data.length === 0){
                        showResults('<div class="gsr-empty"><i class="bi bi-search me-1"></i>No results for "' + q + '"</div>');
                        return;
                    }
                    var html = '<div class="gsr-header">Locations</div>';
                    data.forEach(function(item){
                        var isWH = item.type === 'Warehouse';
                        var href = CTX + '/' + (isWH ? 'warehouse' : 'deliveryPoint') + '/show/' + item.id;
                        html += '<a class="gsr-item" href="' + href + '">'
                            + '<span class="gsr-badge' + (isWH ? '' : ' dp') + '">' + item.type + '</span>'
                            + '<span>' + item.name + ' <small style="color:rgba(0,0,0,0.38);font-weight:600;">(' + item.code + ')</small></span>'
                            + '<span class="gsr-coords">(' + item.x + ', ' + item.y + ')</span>'
                            + '</a>';
                    });
                    showResults(html);
                })
                .catch(function(){ closeResults(); });
        }, 250);
    });

    document.addEventListener('click', function(e){
        if (!searchInput.contains(e.target) && !resultsBox.contains(e.target)) closeResults();
    });
    searchInput.addEventListener('keydown', function(e){
        if (e.key === 'Escape'){ closeResults(); this.blur(); }
    });
})();
</script>
</body>
</html>
