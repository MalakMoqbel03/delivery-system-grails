<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Add Warehouse</title>
    <asset:stylesheet src="dashboard.css"/>
    <style>
    #coordMap {
        width:100%; height:380px; border-radius:14px;
        border:2px solid rgba(0,0,0,0.08);
        position:relative; overflow:hidden; cursor:crosshair; user-select:none;
    }
    .map-terrain-grass { position:absolute; background:#c8e6a0; }
    .map-terrain-road  { position:absolute; background:#f5e6c8; }
    .map-terrain-water { position:absolute; background:#a8d8ea; border-radius:8px; }
    .map-terrain-park  { position:absolute; background:#a4d4a2; border-radius:6px; }
    .map-terrain-block { position:absolute; background:#e8e0d8; border-radius:3px; }
    .map-grid-line     { position:absolute; pointer-events:none; }
    .map-axis-x        { position:absolute; background:rgba(100,80,60,0.25); height:2px; width:100%; pointer-events:none; }
    .map-axis-y        { position:absolute; background:rgba(100,80,60,0.25); width:2px; height:100%; pointer-events:none; }
    .map-label         { position:absolute; font-size:9px; font-weight:800; color:rgba(80,60,40,0.55); pointer-events:none; z-index:5; }
    .map-pin-wh {
        position:absolute; width:20px; height:20px;
        background:#f59e0b; border:3px solid #92400e; border-radius:4px;
        transform:translate(-50%,-50%); pointer-events:none; z-index:10;
        box-shadow:0 3px 8px rgba(0,0,0,0.25);
    }
    .map-pin-wh::after { content:'🏭'; position:absolute; font-size:10px; top:50%; left:50%; transform:translate(-50%,-50%); }
    .map-pin-dp {
        position:absolute; width:18px; height:18px;
        background:#3b82f6; border:3px solid #1e3a8a; border-radius:50%;
        transform:translate(-50%,-50%); pointer-events:none; z-index:10;
        box-shadow:0 3px 8px rgba(0,0,0,0.25);
    }
    .map-pin-dp::after { content:'📦'; position:absolute; font-size:9px; top:50%; left:50%; transform:translate(-50%,-50%); }
    .map-pin-label {
        position:absolute; font-size:8px; font-weight:900; color:#111;
        background:rgba(255,255,255,0.9); padding:1px 4px; border-radius:4px;
        white-space:nowrap; pointer-events:none; transform:translate(-50%,-28px);
        z-index:11; box-shadow:0 1px 4px rgba(0,0,0,0.15);
    }
    .map-house { position:absolute; font-size:14px; pointer-events:none; z-index:6; filter:drop-shadow(0 1px 2px rgba(0,0,0,0.3)); }
    #mapPin {
        position:absolute; display:none; z-index:20;
        width:32px; height:32px; border-radius:50% 50% 50% 0;
        transform:rotate(-45deg) translate(-50%,-50%);
        background:#f59e0b; box-shadow:0 4px 16px rgba(245,158,11,0.55);
        pointer-events:none; transition:left 60ms,top 60ms;
    }
    #mapPin::after { content:'🏭'; position:absolute; font-size:13px; top:50%; left:50%; transform:rotate(45deg) translate(-50%,-50%); }
    #mapHint { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:6px; pointer-events:none; z-index:15; }
    #mapHint i    { font-size:36px; color:rgba(245,158,11,0.45); }
    #mapHint span { font-size:14px; font-weight:800; color:rgba(245,158,11,0.60); }
    #coordReadout { margin-top:8px; min-height:22px; font-size:12px; font-weight:700; color:rgba(0,0,0,0.55); }
    .map-legend { display:flex; gap:12px; flex-wrap:wrap; margin-top:10px; font-size:11px; font-weight:700; color:rgba(0,0,0,0.55); }
    .map-legend-item { display:flex; align-items:center; gap:5px; }
    .map-legend-dot  { width:12px; height:12px; border-radius:3px; }
    /* Code input styles */
    .code-wrap { display:flex; align-items:stretch; border:1px solid rgba(0,0,0,0.12); border-radius:12px; overflow:hidden; background:#fff; transition:border-color 120ms,box-shadow 120ms; }
    .code-wrap:focus-within { border-color:#f59e0b; box-shadow:0 0 0 3px rgba(245,158,11,0.12); }
    .code-prefix { padding:10px 10px 10px 14px; font-size:14px; font-weight:900; color:#d97706; background:rgba(245,158,11,0.08); border-right:1px solid rgba(0,0,0,0.08); white-space:nowrap; display:flex; align-items:center; }
    .code-num { flex:1; border:none; outline:none; padding:10px 12px; font-size:14px; font-weight:700; background:transparent; }
    .code-num::-webkit-inner-spin-button,.code-num::-webkit-outer-spin-button { -webkit-appearance:none; }
    .code-num[type=number] { -moz-appearance:textfield; }
    .code-suggestions { display:flex; gap:6px; margin-top:6px; flex-wrap:wrap; }
    .code-suggest-btn { padding:4px 10px; border-radius:999px; font-size:12px; font-weight:800; border:1.5px solid rgba(245,158,11,0.40); color:#d97706; background:rgba(245,158,11,0.07); cursor:pointer; transition:background 100ms,border-color 100ms; }
    .code-suggest-btn:hover { background:rgba(245,158,11,0.18); border-color:#f59e0b; }
    .code-suggest-btn.taken { opacity:0.35; cursor:not-allowed; text-decoration:line-through; }
    .code-msg { min-height:20px; margin-top:4px; font-size:12px; font-weight:700; }
    .code-msg.ok { color:#059669; } .code-msg.taken { color:#dc2626; } .code-msg.wait { color:rgba(0,0,0,0.38); }
    #submitBtn:disabled { opacity:0.5; cursor:not-allowed; }
    </style>
</head>
<body>
<g:set var="ctx" value="${request.contextPath ?: ''}"/>
<div class="ds-dashboard">
    <div class="ds-header-row">
        <div>
            <h1 class="ds-title">Add New Warehouse</h1>
            <p class="ds-subtitle mb-0">Register a new storage facility in the system.</p>
        </div>
        <div class="ds-header-actions">
            <g:link action="index" class="ds-btn ds-btn-secondary">← Back to list</g:link>
        </div>
    </div>

    <g:if test="${flash.message}"><div class="ds-flash mb-3">${flash.message}</div></g:if>
    <g:hasErrors bean="${this.warehouse}">
        <div class="ds-error-box mb-3"><ul class="list-unstyled mb-0">
            <g:eachError bean="${this.warehouse}" var="error">
                <li><i class="bi bi-exclamation-circle me-1"></i><g:message error="${error}"/></li>
            </g:eachError>
        </ul></div>
    </g:hasErrors>

    <div class="row g-4">
        <!-- Form -->
        <div class="col-lg-5">
            <div class="ds-card">
                <div class="ds-card-header mb-3"><h2 class="ds-card-title mb-0">Warehouse Details</h2></div>
            <%-- Submits to WarehouseController.save() --%>
                <g:form action="save" controller="warehouse" method="POST" elementId="mainForm">
                    <div class="ds-form-row">
                        <label class="ds-form-label">Name *</label>
                        <g:textField name="name" value="${this.warehouse?.name}" class="ds-input" placeholder="e.g. North Hub"/>
                    </div>

                    <div class="ds-form-row">
                        <label class="ds-form-label">Code * <span style="font-weight:600;color:rgba(0,0,0,0.38);">(unique)</span></label>
                        <div class="code-wrap">
                            <span class="code-prefix">WH_</span>
                            <input type="number" id="codeNum" class="code-num" placeholder="001" min="1" max="9999"
                                   value="${this.warehouse?.code ? this.warehouse.code.replace('WH_','') : ''}"/>
                        </div>
                        <input type="hidden" name="code" id="codeHidden" value="${this.warehouse?.code ?: ''}"/>
                        <div class="code-suggestions" id="codeSuggestions"></div>
                        <div class="code-msg" id="codeMsg"></div>
                    </div>

                    <div class="row g-2">
                        <div class="col-6">
                            <div class="ds-form-row">
                                <label class="ds-form-label">X Coordinate *</label>
                                <input type="number" step="0.1" name="x" id="xField" value="${this.warehouse?.x ?: ''}" class="ds-input" placeholder="0.0"/>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="ds-form-row">
                                <label class="ds-form-label">Y Coordinate *</label>
                                <input type="number" step="0.1" name="y" id="yField" value="${this.warehouse?.y ?: ''}" class="ds-input" placeholder="0.0"/>
                            </div>
                        </div>
                    </div>
                    <p style="font-size:11px;color:rgba(245,158,11,0.8);font-weight:700;margin:-4px 0 12px;">
                        <i class="bi bi-arrow-right me-1"></i>Or click the map to place the warehouse
                    </p>

                    <div class="ds-form-row">
                        <label class="ds-form-label">Max Capacity *</label>
                        <input type="number" name="maxCapacity" value="${this.warehouse?.maxCapacity ?: ''}" min="1" class="ds-input" placeholder="100"/>
                    </div>
                    <div class="ds-form-row">
                        <label class="ds-form-label">Current Load *</label>
                        <input type="number" name="currentLoad" value="${this.warehouse?.currentLoad ?: 0}" min="0" class="ds-input"/>
                    </div>

                    <div class="mt-4">
                        <button type="submit" id="submitBtn" class="ds-btn ds-btn-primary" disabled>Create Warehouse</button>
                    </div>
                </g:form>
            </div>
        </div>

        <!-- Colorful map -->
        <div class="col-lg-7">
            <div class="ds-card">
                <div class="ds-card-header mb-3">
                    <div><h2 class="ds-card-title mb-0">City Map</h2>
                        <div class="ds-card-subtitle">Click to place your warehouse</div></div>
                    <span style="font-size:11px;font-weight:700;color:rgba(0,0,0,0.38);">Grid: −50 to +50</span>
                </div>
                <div id="coordMap">
                    <div id="mapHint"><i class="bi bi-geo-alt-fill"></i><span>Click to place the warehouse</span></div>
                    <div id="mapPin"></div>
                </div>
                <div id="coordReadout"></div>
                <div class="map-legend">
                    <div class="map-legend-item"><div class="map-legend-dot" style="background:#f59e0b;border:2px solid #92400e;border-radius:3px;"></div> Warehouse</div>
                    <div class="map-legend-item"><div class="map-legend-dot" style="background:#3b82f6;border:2px solid #1e3a8a;border-radius:50%;"></div> Delivery Point</div>
                    <div class="map-legend-item">🏠 Houses &nbsp;🌳 Parks</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    (function(){
        var CTX='${ctx}', RANGE=50;
        var map=document.getElementById('coordMap'), pin=document.getElementById('mapPin'),
            hint=document.getElementById('mapHint'), readout=document.getElementById('coordReadout'),
            xField=document.getElementById('xField'), yField=document.getElementById('yField');

        /* Build colorful city terrain */
        function buildTerrain(){
            var grass=document.createElement('div'); grass.className='map-terrain-grass'; grass.style.cssText='inset:0;position:absolute;'; map.insertBefore(grass,map.firstChild);
            [{x:0,y:'48%',w:'100%',h:'7px'},{x:'48%',y:0,w:'7px',h:'100%'},{x:0,y:'25%',w:'100%',h:'4px'},{x:0,y:'73%',w:'100%',h:'4px'},{x:'22%',y:0,w:'4px',h:'100%'},{x:'74%',y:0,w:'4px',h:'100%'}].forEach(function(r){var d=document.createElement('div');d.className='map-terrain-road';d.style.cssText='position:absolute;left:'+r.x+';top:'+r.y+';width:'+r.w+';height:'+r.h+';';map.appendChild(d);});
            var rv=document.createElement('div');rv.className='map-terrain-water';rv.style.cssText='position:absolute;left:60%;top:55%;width:28%;height:18%;border-radius:40% 60% 50% 30%;';map.appendChild(rv);
            [{l:'5%',t:'55%',w:'13%',h:'12%'},{l:'55%',t:'5%',w:'11%',h:'13%'}].forEach(function(p){var d=document.createElement('div');d.className='map-terrain-park';d.style.cssText='position:absolute;left:'+p.l+';top:'+p.t+';width:'+p.w+';height:'+p.h+';';map.appendChild(d);});
            [{l:'8%',t:'8%',w:'11%',h:'14%'},{l:'26%',t:'5%',w:'17%',h:'17%'},{l:'8%',t:'30%',w:'11%',h:'14%'},{l:'26%',t:'28%',w:'17%',h:'17%'},{l:'53%',t:'28%',w:'17%',h:'17%'},{l:'78%',t:'5%',w:'16%',h:'17%'},{l:'8%',t:'52%',w:'11%',h:'20%'},{l:'26%',t:'52%',w:'17%',h:'17%'},{l:'78%',t:'52%',w:'16%',h:'20%'},{l:'78%',t:'28%',w:'16%',h:'20%'}].forEach(function(b){var d=document.createElement('div');d.className='map-terrain-block';d.style.cssText='position:absolute;left:'+b.l+';top:'+b.t+';width:'+b.w+';height:'+b.h+';border:1px solid rgba(0,0,0,0.06);';map.appendChild(d);});
            [{l:9,t:9},{l:14,t:11},{l:9,t:14},{l:29,t:7},{l:36,t:7},{l:29,t:13},{l:36,t:13},{l:9,t:31},{l:14,t:31},{l:9,t:36},{l:29,t:30},{l:36,t:30},{l:55,t:30},{l:62,t:30},{l:55,t:37},{l:80,t:7},{l:86,t:7},{l:80,t:13},{l:80,t:54},{l:86,t:54},{l:80,t:60},{l:80,t:30},{l:86,t:30},{l:80,t:36},{l:29,t:54},{l:36,t:54},{l:29,t:60},{l:36,t:60},{l:9,t:72},{l:14,t:72}].forEach(function(h){var el=document.createElement('div');el.className='map-house';el.style.cssText='left:'+h.l+'%;top:'+h.t+'%;';el.textContent='🏠';map.appendChild(el);});
            [{l:7,t:57},{l:10,t:62},{l:13,t:58},{l:57,t:7},{l:61,t:10},{l:64,t:7}].forEach(function(t){var el=document.createElement('div');el.className='map-house';el.style.cssText='left:'+t.l+'%;top:'+t.t+'%;';el.textContent='🌳';map.appendChild(el);});
            for(var i=0;i<=10;i++){var dv=document.createElement('div');dv.className='map-grid-line';dv.style.cssText='position:absolute;left:'+(i/10*100)+'%;top:0;width:1px;height:100%;background:rgba(0,0,0,0.06);';map.appendChild(dv);var dh=document.createElement('div');dh.className='map-grid-line';dh.style.cssText='position:absolute;top:'+(i/10*100)+'%;left:0;height:1px;width:100%;background:rgba(0,0,0,0.06);';map.appendChild(dh);}
            var ax=document.createElement('div');ax.className='map-axis-x';ax.style.top='50%';map.appendChild(ax);
            var ay=document.createElement('div');ay.className='map-axis-y';ay.style.left='50%';map.appendChild(ay);
            var hq=document.createElement('div');hq.className='map-label';hq.style.cssText='left:calc(50% + 5px);top:calc(50% + 4px);';hq.textContent='HQ (0,0)';map.appendChild(hq);
        }
        buildTerrain();

        function pxToCoord(px,py){return{x:+((px/map.clientWidth*2*RANGE)-RANGE).toFixed(1),y:+(RANGE-(py/map.clientHeight*2*RANGE)).toFixed(1)};}
        function coordToPx(x,y){return{px:((+x+RANGE)/(2*RANGE))*map.clientWidth,py:((RANGE-+y)/(2*RANGE))*map.clientHeight};}
        function placePin(px,py,x,y){
            pin.style.left=px+'px';pin.style.top=py+'px';pin.style.display='block';hint.style.display='none';
            readout.innerHTML='<i class="bi bi-geo-alt-fill me-1" style="color:#f59e0b;"></i>Selected: <strong>X='+x+'</strong>, <strong>Y='+y+'</strong>';
            xField.value=x;yField.value=y;
        }
        map.addEventListener('click',function(e){var r=map.getBoundingClientRect();var c=pxToCoord(e.clientX-r.left,e.clientY-r.top);var p=coordToPx(c.x,c.y);placePin(p.px,p.py,c.x,c.y);});
        function syncToMap(){var x=parseFloat(xField.value),y=parseFloat(yField.value);if(!isNaN(x)&&!isNaN(y)){var p=coordToPx(x,y);placePin(p.px,p.py,x,y);}}
        xField.addEventListener('input',syncToMap);yField.addEventListener('input',syncToMap);
        if(xField.value&&yField.value)syncToMap();

        /* Load existing location pins — calls LocationService.search() via /location/search */
        fetch(CTX+'/location/search?q=').then(function(r){return r.json();}).catch(function(){return[];}).then(function(locs){
            locs.forEach(function(loc){
                if(isNaN(loc.x)||isNaN(loc.y))return;
                var p=coordToPx(loc.x,loc.y);
                var dot=document.createElement('div');dot.className=loc.type==='Warehouse'?'map-pin-wh':'map-pin-dp';dot.style.left=p.px+'px';dot.style.top=p.py+'px';map.appendChild(dot);
                var lbl=document.createElement('div');lbl.className='map-pin-label';lbl.style.left=p.px+'px';lbl.style.top=p.py+'px';lbl.textContent=loc.code;map.appendChild(lbl);
            });
        });

        /* Code field — checks uniqueness via WarehouseController.checkCode() */
        var codeNum=document.getElementById('codeNum'), codeHidden=document.getElementById('codeHidden'),
            codeMsg=document.getElementById('codeMsg'), submitBtn=document.getElementById('submitBtn'),
            suggestionsDiv=document.getElementById('codeSuggestions'), debounce=null, takenCodes=new Set();

        function generateSuggestions(){
            suggestionsDiv.innerHTML='';
            var nums=[String(Math.floor(Math.random()*900)+100),String(Math.floor(Math.random()*900)+100),String(Math.floor(Math.random()*900)+100)];
            nums=[...new Set(nums)];
            nums.forEach(function(num){
                var full='WH_'+num,btn=document.createElement('button');
                btn.type='button';btn.className='code-suggest-btn';btn.textContent=full;
                if(takenCodes.has(full))btn.classList.add('taken');
                btn.addEventListener('click',function(){if(btn.classList.contains('taken'))return;codeNum.value=num;checkCode();});
                suggestionsDiv.appendChild(btn);
            });
        }
        generateSuggestions();

        function setMsg(type,text){
            codeMsg.className='code-msg '+(type||'');codeMsg.textContent=text;
            var blocked=(type==='taken');
            submitBtn.disabled=blocked||!codeNum.value.trim();
            submitBtn.textContent=blocked?'Choose another number ↑':'Create Warehouse';
        }
        function checkCode(){
            var num=codeNum.value.trim();
            if(!num){codeHidden.value='';setMsg('','');submitBtn.disabled=true;return;}
            var full='WH_'+num;codeHidden.value=full;setMsg('wait','Checking…');
            clearTimeout(debounce);
            debounce=setTimeout(function(){
                fetch(CTX+'/warehouse/checkCode?code='+encodeURIComponent(full))
                    .then(function(r){return r.json();})
                    .then(function(data){
                        if(data.available){setMsg('ok','✓ '+full+' is available');}
                        else{takenCodes.add(full);setMsg('taken','✗ '+full+' is already taken');generateSuggestions();}
                    }).catch(function(){setMsg('ok','');});
            },350);
        }
        codeNum.addEventListener('input',checkCode);
        document.getElementById('mainForm').addEventListener('submit',function(e){if(!codeNum.value.trim()){e.preventDefault();setMsg('taken','Please enter a code number');return;}if(submitBtn.disabled)e.preventDefault();});
        if(codeNum.value)checkCode();
    })();
</script>
</body>
</html>
