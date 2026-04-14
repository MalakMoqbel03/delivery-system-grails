<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>My Deliveries</title>
    <asset:stylesheet src="dashboard.css"/>
    <style>
        /* ── KPI strip ── */
        .ud-kpi-row{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:22px;}
        @media(max-width:576px){.ud-kpi-row{grid-template-columns:1fr;}}
        .ud-kpi{background:#fff;border:1px solid rgba(0,0,0,0.07);border-radius:16px;padding:16px;display:flex;align-items:center;gap:14px;}
        .ud-kpi-icon{width:46px;height:46px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
        .ud-kpi-icon-pending  {background:rgba(59,130,246,0.10); color:#1d4ed8;}
        .ud-kpi-icon-transit  {background:rgba(245,158,11,0.12); color:#b45309;}
        .ud-kpi-icon-delivered{background:rgba(16,185,129,0.12); color:#0f766e;}
        .ud-kpi-num{font-size:28px;font-weight:900;letter-spacing:-0.03em;line-height:1;}
        .ud-kpi-lbl{font-size:12px;font-weight:800;color:rgba(0,0,0,0.50);margin-top:3px;}

        /* ── Filter tabs ── */
        .ud-tabs{display:flex;gap:8px;margin-bottom:16px;flex-wrap:wrap;}
        .ud-tab{display:inline-flex;align-items:center;gap:6px;padding:7px 16px;border-radius:999px;
                font-size:13px;font-weight:800;border:1.5px solid transparent;
                background:none;cursor:pointer;transition:all 120ms;}
        .ud-tab-all      {border-color:rgba(0,0,0,0.12);     color:rgba(0,0,0,0.60);}
        .ud-tab-pending  {border-color:rgba(59,130,246,0.25); color:#1d4ed8;  background:rgba(59,130,246,0.06);}
        .ud-tab-transit  {border-color:rgba(245,158,11,0.25); color:#b45309;  background:rgba(245,158,11,0.06);}
        .ud-tab-delivered{border-color:rgba(16,185,129,0.25); color:#0f766e;  background:rgba(16,185,129,0.06);}
        .ud-tab.active,.ud-tab:hover{box-shadow:0 2px 10px rgba(0,0,0,0.09);}
        .ud-tab-all.active{background:rgba(0,0,0,0.05);border-color:rgba(0,0,0,0.18);color:#111;}
        .ud-count{font-size:11px;font-weight:900;padding:1px 7px;border-radius:999px;background:rgba(0,0,0,0.07);}
        .ud-tab-pending   .ud-count{background:rgba(59,130,246,0.14);color:#1d4ed8;}
        .ud-tab-transit   .ud-count{background:rgba(245,158,11,0.14);color:#b45309;}
        .ud-tab-delivered .ud-count{background:rgba(16,185,129,0.14);color:#0f766e;}

        /* ── Assignment cards ── */
        .ud-grid{display:flex;flex-direction:column;gap:10px;}
        .ud-card{background:#fff;border:1px solid rgba(0,0,0,0.07);border-radius:16px;
                 padding:16px 18px;display:flex;align-items:center;gap:16px;
                 transition:box-shadow 140ms,transform 140ms;}
        .ud-card:hover{box-shadow:0 6px 24px rgba(0,0,0,0.08);transform:translateY(-1px);}

        .ud-card-icon{width:44px;height:44px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
        .ud-icon-pending  {background:rgba(59,130,246,0.10); color:#1d4ed8;}
        .ud-icon-transit  {background:rgba(245,158,11,0.12); color:#b45309;}
        .ud-icon-delivered{background:rgba(16,185,129,0.12); color:#0f766e;}

        .ud-card-body{flex:1;min-width:0;}
        .ud-card-title{font-weight:900;font-size:15px;color:rgba(0,0,0,0.88);
                       white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
        .ud-card-meta{font-size:12px;color:rgba(0,0,0,0.48);font-weight:700;margin-top:3px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;}

        .ud-priority-dot{width:8px;height:8px;border-radius:50%;display:inline-block;flex-shrink:0;}
        .ud-dot-HIGH  {background:#ef4444;}
        .ud-dot-MEDIUM{background:#f59e0b;}
        .ud-dot-LOW   {background:#10b981;}

        .ud-card-right{display:flex;align-items:center;gap:8px;flex-shrink:0;}

        /* Advance button */
        .ud-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;
                border-radius:10px;font-size:12px;font-weight:800;border:none;cursor:pointer;
                text-decoration:none;transition:background 120ms;}
        .ud-btn-start  {background:rgba(59,130,246,0.10);color:#1d4ed8;}
        .ud-btn-start:hover  {background:rgba(59,130,246,0.18);}
        .ud-btn-deliver{background:rgba(245,158,11,0.12);color:#b45309;}
        .ud-btn-deliver:hover{background:rgba(245,158,11,0.22);}
        .ud-done{display:inline-flex;align-items:center;gap:4px;font-size:12px;font-weight:800;
                 color:#0f766e;padding:6px 12px;border-radius:10px;background:rgba(16,185,129,0.10);}

        .ud-empty{text-align:center;padding:48px 20px;color:rgba(0,0,0,0.38);font-weight:800;font-size:15px;}
        .ud-empty i{font-size:36px;display:block;margin-bottom:10px;opacity:.4;}
    </style>
</head>
<body>
<g:set var="ctx" value="${request.contextPath ?: ''}"/>

<div class="ds-dashboard">

    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">My Deliveries</h1>
            <p class="ds-subtitle mb-0">Advance each assignment as you complete it.</p>
        </div>
    </div>

    <%-- Flash --%>
    <g:if test="${flash.message}">
        <div class="ds-flash mb-3"><i class="bi bi-check-circle-fill me-2"></i>${flash.message}</div>
    </g:if>
    <g:if test="${flash.error}">
        <div class="ds-error-box mb-3"><i class="bi bi-exclamation-triangle-fill me-2"></i>${flash.error}</div>
    </g:if>

    <%-- KPI strip --%>
    <div class="ud-kpi-row">
        <div class="ud-kpi">
            <div class="ud-kpi-icon ud-kpi-icon-pending"><i class="bi bi-hourglass-split"></i></div>
            <div>
                <div class="ud-kpi-num">${pendingCount}</div>
                <div class="ud-kpi-lbl">Pending</div>
            </div>
        </div>
        <div class="ud-kpi">
            <div class="ud-kpi-icon ud-kpi-icon-transit"><i class="bi bi-truck"></i></div>
            <div>
                <div class="ud-kpi-num">${inTransitCount}</div>
                <div class="ud-kpi-lbl">In Transit</div>
            </div>
        </div>
        <div class="ud-kpi">
            <div class="ud-kpi-icon ud-kpi-icon-delivered"><i class="bi bi-check2-circle"></i></div>
            <div>
                <div class="ud-kpi-num">${deliveredCount}</div>
                <div class="ud-kpi-lbl">Delivered</div>
            </div>
        </div>
    </div>

    <%-- Filter tabs --%>
    <div class="ud-tabs">
        <button class="ud-tab ud-tab-all active" onclick="filter('ALL',this)">
            All <span class="ud-count">${totalCount}</span>
        </button>
        <button class="ud-tab ud-tab-pending" onclick="filter('PENDING',this)">
            <i class="bi bi-hourglass-split" style="font-size:12px;"></i> Pending
            <span class="ud-count">${pendingCount}</span>
        </button>
        <button class="ud-tab ud-tab-transit" onclick="filter('IN_TRANSIT',this)">
            <i class="bi bi-truck" style="font-size:12px;"></i> In Transit
            <span class="ud-count">${inTransitCount}</span>
        </button>
        <button class="ud-tab ud-tab-delivered" onclick="filter('DELIVERED',this)">
            <i class="bi bi-check2-circle" style="font-size:12px;"></i> Delivered
            <span class="ud-count">${deliveredCount}</span>
        </button>
    </div>

    <%-- Cards --%>
    <div class="ud-grid" id="ud-grid">
        <g:each in="${allAssignments}" var="a">
            <g:set var="isTransit"   value="${a.status == 'IN_TRANSIT'}"/>
            <g:set var="isPending"   value="${a.status == 'PENDING'}"/>
            <g:set var="isDelivered" value="${a.status == 'DELIVERED'}"/>

            <div class="ud-card" data-status="${a.status}">

                <%-- Icon --%>
                <div class="ud-card-icon ${isPending ? 'ud-icon-pending' : (isTransit ? 'ud-icon-transit' : 'ud-icon-delivered')}">
                    <i class="bi ${isPending ? 'bi-hourglass-split' : (isTransit ? 'bi-truck' : 'bi-check2-circle')}"></i>
                </div>

                <%-- Body --%>
                <div class="ud-card-body">
                    <div class="ud-card-title">
                        <i class="bi bi-boxes" style="font-size:11px;opacity:.5;"></i>
                        ${a.warehouse.name}
                        <span style="opacity:.35;font-weight:500;margin:0 5px;">→</span>
                        <i class="bi bi-geo-alt" style="font-size:11px;opacity:.5;"></i>
                        ${a.deliveryPoint.name}
                    </div>
                    <div class="ud-card-meta">
                        <span class="ud-priority-dot ud-dot-${a.deliveryPoint.priority}"></span>
                        ${a.deliveryPoint.priority} priority
                        <span style="opacity:.3;">·</span>
                        ${a.deliveryPoint.deliveryArea}
                        <span style="opacity:.3;">·</span>
                        <g:formatDate date="${a.assignedAt}" format="dd MMM yyyy, HH:mm"/>
                    </div>
                </div>

                <%-- Status + action --%>
                <div class="ud-card-right">
                    <span class="ds-pill ds-pill-status-${a.status.toLowerCase()}">${a.status.replace('_', ' ')}</span>

                    <g:if test="${isPending}">
                        <g:form controller="userDashboard" action="updateStatus" id="${a.id}" method="post" style="margin:0;">
                            <button type="submit" class="ud-btn ud-btn-start" title="Mark as In Transit">
                                <i class="bi bi-play-fill" style="font-size:11px;"></i> Start
                            </button>
                        </g:form>
                    </g:if>
                    <g:elseif test="${isTransit}">
                        <g:form controller="userDashboard" action="updateStatus" id="${a.id}" method="post" style="margin:0;">
                            <button type="submit" class="ud-btn ud-btn-deliver" title="Mark as Delivered">
                                <i class="bi bi-check-lg" style="font-size:11px;"></i> Deliver
                            </button>
                        </g:form>
                    </g:elseif>
                    <g:else>
                        <span class="ud-done"><i class="bi bi-check2-all" style="font-size:13px;"></i> Done</span>
                    </g:else>
                </div>
            </div>
        </g:each>

        <g:if test="${!allAssignments}">
            <div class="ud-empty">
                <i class="bi bi-inbox"></i>
                No assignments yet — check back later.
            </div>
        </g:if>
    </div>
</div>

<script>
(function(){
    window.filter = function(status, btn) {
        document.querySelectorAll('.ud-tab').forEach(function(t){ t.classList.remove('active'); });
        btn.classList.add('active');
        document.querySelectorAll('#ud-grid .ud-card').forEach(function(c){
            c.style.display = (status === 'ALL' || c.dataset.status === status) ? '' : 'none';
        });
    };
})();
</script>
</body>
</html>
