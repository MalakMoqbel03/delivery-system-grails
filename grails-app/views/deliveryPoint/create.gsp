<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Add Delivery Point</title>
    <asset:stylesheet src="dashboard.css"/>
    <style>
        #coordMap{width:100%;height:340px;border-radius:14px;border:2px solid rgba(0,0,0,0.08);
            background:#f0fff4;position:relative;overflow:hidden;cursor:crosshair;user-select:none;}
        .map-grid-line{position:absolute;background:rgba(16,185,129,0.08);pointer-events:none;}
        .map-axis-line{position:absolute;background:rgba(16,185,129,0.22);pointer-events:none;}
        .map-label{position:absolute;font-size:10px;font-weight:700;color:rgba(16,185,129,0.55);pointer-events:none;}
        #mapPin{position:absolute;display:none;width:28px;height:28px;border-radius:50% 50% 50% 0;
            transform:rotate(-45deg) translate(-50%,-50%);background:#10b981;
            box-shadow:0 4px 16px rgba(16,185,129,0.45);pointer-events:none;transition:left 60ms,top 60ms;}
        #mapPin::after{content:'';position:absolute;width:10px;height:10px;border-radius:50%;background:#fff;top:50%;left:50%;transform:translate(-50%,-50%);}
        #mapHint{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;pointer-events:none;}
        #mapHint i{font-size:32px;color:rgba(16,185,129,0.28);}
        #mapHint span{font-size:13px;font-weight:700;color:rgba(16,185,129,0.42);}
        #coordReadout{margin-top:8px;min-height:20px;font-size:12px;font-weight:700;color:rgba(0,0,0,0.5);}
        .map-other-pin{position:absolute;width:10px;height:10px;border-radius:50%;
            background:rgba(16,185,129,0.35);border:2px solid #10b981;transform:translate(-50%,-50%);pointer-events:none;}
        .map-other-label{position:absolute;font-size:9px;font-weight:800;color:rgba(16,185,129,0.65);
            white-space:nowrap;transform:translate(-50%,-18px);pointer-events:none;}
        .code-wrap{display:flex;align-items:stretch;border:1px solid rgba(0,0,0,0.12);border-radius:12px;overflow:hidden;background:#fff;transition:border-color 120ms,box-shadow 120ms;}
        .code-wrap:focus-within{border-color:#10b981;box-shadow:0 0 0 3px rgba(16,185,129,0.12);}
        .code-prefix{padding:10px 10px 10px 14px;font-size:14px;font-weight:900;color:#059669;letter-spacing:.03em;background:rgba(16,185,129,0.07);border-right:1px solid rgba(0,0,0,0.08);white-space:nowrap;display:flex;align-items:center;}
        .code-num{flex:1;border:none;outline:none;padding:10px 12px;font-size:14px;font-weight:700;background:transparent;}
        .code-num::-webkit-inner-spin-button,.code-num::-webkit-outer-spin-button{-webkit-appearance:none;}
        .code-num[type=number]{-moz-appearance:textfield;}
        .code-suggestions{display:flex;gap:6px;margin-top:6px;flex-wrap:wrap;}
        .code-suggest-btn{padding:4px 10px;border-radius:999px;font-size:12px;font-weight:800;border:1.5px solid rgba(16,185,129,0.30);color:#059669;background:rgba(16,185,129,0.06);cursor:pointer;transition:background 100ms,border-color 100ms;}
        .code-suggest-btn:hover{background:rgba(16,185,129,0.14);border-color:#10b981;}
        .code-suggest-btn.taken{opacity:0.35;cursor:not-allowed;text-decoration:line-through;}
        .code-msg{min-height:20px;margin-top:4px;font-size:12px;font-weight:700;}
        .code-msg.ok{color:#059669;}.code-msg.taken{color:#dc2626;}.code-msg.wait{color:rgba(0,0,0,0.38);}
        #submitBtn:disabled{background:rgba(239,68,68,0.08)!important;color:#b91c1c!important;border-color:rgba(239,68,68,0.20)!important;cursor:not-allowed;}
    </style>
</head>
<body>
<g:set var="ctx" value="${request.contextPath ?: ''}"/>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div><h1 class="ds-title">Add New Delivery Point</h1><p class="ds-subtitle mb-0">Register a new delivery destination.</p></div>
        <div class="ds-header-actions"><g:link action="index" class="ds-btn ds-btn-secondary">← Back to list</g:link></div>
    </div>

    <g:if test="${flash.message}"><div class="ds-flash mb-3">${flash.message}</div></g:if>
    <g:hasErrors bean="${this.deliveryPoint}">
        <div class="ds-error-box mb-3"><ul class="list-unstyled mb-0">
            <g:eachError bean="${this.deliveryPoint}" var="error">
                <li><i class="bi bi-exclamation-circle me-1"></i><g:message error="${error}"/></li>
            </g:eachError>
        </ul></div>
    </g:hasErrors>

    <div class="row g-4">
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-3"><h2 class="ds-card-title mb-0">Delivery Point Details</h2></div>
                <g:form resource="${this.deliveryPoint}" controller="deliveryPoint" method="POST" id="mainForm">
                    <div class="ds-form-row">
                        <label class="ds-form-label">Name *</label>
                        <g:textField name="name" value="${this.deliveryPoint?.name}" class="ds-input" placeholder="e.g. Downtown Hub"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Code * <span style="font-weight:600;color:rgba(0,0,0,0.38);">(unique)</span></label>
                        <div class="code-wrap">
                            <span class="code-prefix">DP</span>                            <input type="number" id="codeNum" class="code-num" placeholder="001" min="1" max="9999"
                                   value="${this.deliveryPoint?.code ? this.deliveryPoint.code.replace('DP_','') : ''}"/>
                        </div>
                        <input type="hidden" name="code" id="codeHidden" value="${this.deliveryPoint?.code ?: ''}"/>
                        <div class="code-suggestions" id="codeSuggestions"></div>
                        <div class="code-msg" id="codeMsg"></div>
                    </div>
                    <div class="row g-2">
                        <div class="col-6"><div class="ds-form-row">
                            <label class="ds-form-label">X Coordinate *</label>
                            <input type="number" step="0.1" name="x" id="xField" value="${this.deliveryPoint?.x ?: ''}" class="ds-input" placeholder="0.0"/>
                        </div></div>
                        <div class="col-6"><div class="ds-form-row">
                            <label class="ds-form-label">Y Coordinate *</label>
                            <input type="number" step="0.1" name="y" id="yField" value="${this.deliveryPoint?.y ?: ''}" class="ds-input" placeholder="0.0"/>
                        </div></div>
                    </div>
                    <p style="font-size:11px;color:rgba(16,185,129,0.75);font-weight:700;margin:-4px 0 12px;">
                        <i class="bi bi-arrow-right me-1"></i>Or click the map on the right to set coordinates
                    </p>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Delivery Area *</label>
                        <g:textField name="deliveryArea" value="${this.deliveryPoint?.deliveryArea}" class="ds-input" placeholder="e.g. North District"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Priority *</label>
                        <g:select name="priority" from="${['LOW','MEDIUM','HIGH']}" value="${this.deliveryPoint?.priority}" class="ds-select"/>
                    </div>
                    <div class="mt-4">
                        <button type="submit" id="submitBtn" class="ds-btn ds-btn-primary" disabled>Create Delivery Point</button>
                    </div>
                </g:form>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="ds-card">
                <div class="ds-card-header mb-3">
                    <div><h2 class="ds-card-title mb-0">Pick Location on Map</h2><div class="ds-card-subtitle">Click anywhere to set X &amp; Y coordinates</div></div>
                    <span style="font-size:11px;font-weight:700;color:rgba(0,0,0,0.38);">Grid: −50 to +50</span>
                </div>
                <div id="coordMap">
                    <div id="mapHint"><i class="bi bi-geo-alt-fill"></i><span>Click to place the delivery point</span></div>
                    <div id="mapPin"></div>
                </div>
                <div id="coordReadout"></div>
                <p style="font-size:11px;color:rgba(0,0,0,0.35);font-weight:600;margin-top:8px;">
                    <i class="bi bi-info-circle me-1"></i>Dots = existing locations. You can also type values directly.
                </p>
            </div>
        </div>
    </div>
</div>
<script>
(function(){
    var CTX='${ctx}', RANGE=50;
    var map=document.getElementById('coordMap'),pin=document.getElementById('mapPin'),
        hint=document.getElementById('mapHint'),readout=document.getElementById('coordReadout'),
        xField=document.getElementById('xField'),yField=document.getElementById('yField');

    function buildGrid(){
        for(var i=0;i<=10;i++){var d=document.createElement('div');d.className='map-grid-line';d.style.cssText='left:'+(i/10*100)+'%;top:0;width:1px;height:100%;';map.appendChild(d);}
        for(var j=0;j<=8;j++){var d2=document.createElement('div');d2.className='map-grid-line';d2.style.cssText='top:'+(j/8*100)+'%;left:0;height:1px;width:100%;';map.appendChild(d2);}
        var ax=document.createElement('div');ax.className='map-axis-line';ax.style.cssText='top:50%;left:0;height:2px;width:100%;';map.appendChild(ax);
        var ay=document.createElement('div');ay.className='map-axis-line';ay.style.cssText='left:50%;top:0;width:2px;height:100%;';map.appendChild(ay);
        var lbl=document.createElement('div');lbl.className='map-label';lbl.style.cssText='left:calc(50% + 5px);top:calc(50% + 4px);';lbl.textContent='HQ (0,0)';map.appendChild(lbl);
    }
    buildGrid();
    function pxToCoord(px,py){return{x:+((px/map.clientWidth*2*RANGE)-RANGE).toFixed(1),y:+(RANGE-(py/map.clientHeight*2*RANGE)).toFixed(1)};}
    function coordToPx(x,y){return{px:((+x+RANGE)/(2*RANGE))*map.clientWidth,py:((RANGE-+y)/(2*RANGE))*map.clientHeight};}
    function placePin(px,py,x,y){pin.style.left=px+'px';pin.style.top=py+'px';pin.style.display='block';hint.style.display='none';readout.innerHTML='<i class="bi bi-geo-alt-fill me-1" style="color:#10b981;"></i>Selected: <strong>X='+x+'</strong>, <strong>Y='+y+'</strong>';xField.value=x;yField.value=y;}
    map.addEventListener('click',function(e){var r=map.getBoundingClientRect();var c=pxToCoord(e.clientX-r.left,e.clientY-r.top);var p=coordToPx(c.x,c.y);placePin(p.px,p.py,c.x,c.y);});
    function syncToMap(){var x=parseFloat(xField.value),y=parseFloat(yField.value);if(!isNaN(x)&&!isNaN(y)){var p=coordToPx(x,y);placePin(p.px,p.py,x,y);}}
    xField.addEventListener('input',syncToMap);yField.addEventListener('input',syncToMap);
    if(xField.value&&yField.value)syncToMap();
    fetch(CTX+'/location/search?q=').then(function(r){return r.json();}).catch(function(){return[];}).then(function(locs){locs.forEach(function(loc){if(isNaN(loc.x)||isNaN(loc.y))return;var p=coordToPx(loc.x,loc.y);var dot=document.createElement('div');dot.className='map-other-pin';dot.style.left=p.px+'px';dot.style.top=p.py+'px';map.appendChild(dot);var lbl=document.createElement('div');lbl.className='map-other-label';lbl.style.left=p.px+'px';lbl.style.top=p.py+'px';lbl.textContent=loc.code;map.appendChild(lbl);});});

    var codeNum=document.getElementById('codeNum'),codeHidden=document.getElementById('codeHidden'),
        codeMsg=document.getElementById('codeMsg'),submitBtn=document.getElementById('submitBtn'),
        suggestions=document.getElementById('codeSuggestions'),debounce=null,takenCodes=new Set();

    function generateSuggestions(){
        suggestions.innerHTML='';
        var nums=[...new Set([String(Math.floor(Math.random()*900)+100),String(Math.floor(Math.random()*900)+100),String(Math.floor(Math.random()*900)+100)])];
        nums.forEach(function(num){
            var full='DP'+num;
            var btn=document.createElement('button');btn.type='button';btn.className='code-suggest-btn';btn.textContent=full;
            if(takenCodes.has(full))btn.classList.add('taken');
            btn.addEventListener('click',function(){if(btn.classList.contains('taken'))return;codeNum.value=num;checkCode();});
            suggestions.appendChild(btn);
        });
    }
    generateSuggestions();

    function setMsg(type,text){
        codeMsg.className='code-msg '+(type||'');codeMsg.textContent=text;
        var blocked=(type==='taken');
        submitBtn.disabled=blocked||!codeNum.value.trim();
        submitBtn.textContent=blocked?'Choose another number ↑':'Create Delivery Point';
    }
    function checkCode(){
        var num=codeNum.value.trim();
        if(!num){codeHidden.value='';setMsg('','');submitBtn.disabled=true;return;}
        var full='DP_'+num;codeHidden.value=full;setMsg('wait','Checking…');
        clearTimeout(debounce);
        debounce=setTimeout(function(){
            fetch(CTX+'/deliveryPoint/checkCode?code='+encodeURIComponent(full))
                .then(function(r){return r.json();})
                .then(function(data){
                    if(data.available){setMsg('ok','✓ '+full+' is available');}
                    else{takenCodes.add(full);setMsg('taken','✗ '+full+' is already taken — choose another');generateSuggestions();}
                }).catch(function(){setMsg('ok','');});
        },350);
    }
    codeNum.addEventListener('input',checkCode);
    document.getElementById('mainForm').addEventListener('submit',function(e){
        if(!codeNum.value.trim()){e.preventDefault();setMsg('taken','Please enter a code number');return;}
        if(submitBtn.disabled)e.preventDefault();
    });
    if(codeNum.value)checkCode();
})();
</script>
</body>
</html>
