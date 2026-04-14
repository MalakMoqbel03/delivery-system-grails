<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Access Denied</title>
    <asset:stylesheet src="dashboard.css"/>
    <style>
        .fb-wrap{min-height:60vh;display:flex;align-items:center;justify-content:center;}
        .fb-card{background:#fff;border:1px solid rgba(0,0,0,0.07);border-radius:24px;
                 padding:52px 44px;max-width:420px;width:100%;text-align:center;
                 box-shadow:0 12px 40px rgba(0,0,0,0.06);}
        .fb-icon{width:72px;height:72px;border-radius:20px;margin:0 auto 22px;
                 background:rgba(239,68,68,0.10);display:flex;align-items:center;
                 justify-content:center;font-size:32px;color:#dc2626;}
        .fb-title{font-size:22px;font-weight:900;letter-spacing:-0.02em;margin-bottom:8px;color:rgba(0,0,0,0.88);}
        .fb-sub{font-size:14px;color:rgba(0,0,0,0.48);font-weight:600;line-height:1.65;margin-bottom:28px;}
        .fb-btn{display:inline-flex;align-items:center;gap:7px;background:#3b82f6;color:#fff;
                padding:10px 22px;border-radius:12px;font-weight:800;font-size:14px;
                text-decoration:none;transition:background 120ms;}
        .fb-btn:hover{background:#2563eb;color:#fff;}
    </style>
</head>
<body>
<div class="fb-wrap">
    <div class="fb-card">
        <div class="fb-icon"><i class="bi bi-shield-lock-fill"></i></div>
        <div class="fb-title">Access denied</div>
        <div class="fb-sub">
            This page is restricted to administrators.<br/>
            Your account does not have permission to view it.
        </div>
        <a href="${request.contextPath}/my" class="fb-btn">
            <i class="bi bi-arrow-left" style="font-size:13px;"></i> Back to my deliveries
        </a>
    </div>
</div>
</body>
</html>
