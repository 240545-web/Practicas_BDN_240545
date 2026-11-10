/* Static Atlas interaction: native Pointer Events and SVG, no backend. */
function enhanceAtlasERD({svg,data,tables,colors,setZoom,getScale}) {
 const $=id=>document.getElementById(id), viewport=$('diagramViewport');
 const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const entities=new Map(), nodeList=[...svg.querySelectorAll('g.node, g[id^="entity-"]')];
 for(const table of tables){
  const node=nodeList.find(n=>n.dataset.table===table.name);
  if(!node)throw new Error('Tabla ausente del SVG: '+table.name);
  entities.set(table.name,node);node.setAttribute('tabindex','0');node.setAttribute('role','button');node.setAttribute('aria-label','Ver campos y totales de '+table.name);
 }
 const paths=[...svg.querySelectorAll('path.relationshipLine, .edgePaths path')];
 // Match the renderer's endpoint IDs, never assume path order equals SQL order.
 const edges=data.relationships.map((rel,i)=>{
  const path=paths.find(p=>!p.dataset.bound && p.id.includes(rel.source+'-') && p.id.includes(rel.target+'-'));
  if(!path)throw new Error('Relación ausente del SVG: '+rel.source+' → '+rel.target);
  path.dataset.bound='true';path.dataset.source=rel.source;path.dataset.target=rel.target;path.style.pointerEvents='stroke';path.style.cursor='pointer';
  const label=svg.querySelector(`[data-id="${CSS.escape(path.id)}"]`)||svg.querySelector(`#${CSS.escape(path.id.replace(/^id_/,''))}`);
  return {...rel,path,label};
 });
 let selected=null, query='', mode='all', keyMode='';
 function highlight(names=new Set(),edge=null){
  const linked=new Set(names);edges.forEach(e=>{if(names.has(e.source)||names.has(e.target)){linked.add(e.source);linked.add(e.target);}});
  entities.forEach((n,name)=>{n.classList.toggle('erd-muted',names.size>0&&!linked.has(name));n.classList.toggle('erd-active',names.has(name));});
  edges.forEach(e=>{const active=edge?e===edge:names.has(e.source)||names.has(e.target);e.path.classList.toggle('erd-muted',names.size>0&&!active);e.path.classList.toggle('erd-edge-active',active);const label=svg.querySelector('[data-edge-label="'+e.path.dataset.relation+'"]');if(label)label.setAttribute('visibility',active?'visible':'hidden');});
 }
 const panel=document.createElement('aside');panel.id='erdDetail';panel.className='erd-detail';panel.hidden=true;panel.setAttribute('aria-label','Detalle de tabla');document.body.append(panel);
 function close(){panel.hidden=true;if(selected)entities.get(selected)?.focus({preventScroll:true});selected=null;highlight();}
 function show(name,category){
  const t=tables.find(t=>t.name===name);selected=name;const stats=t.stats;
  panel.innerHTML=`<button class="small-btn erd-close" aria-label="Cerrar detalle">Cerrar ×</button><h3 tabindex="-1">${esc(name)}</h3><p>${esc(t.description)}</p><div class="erd-totals"><span>Campos <b>${stats.fields}</b></span><span>Filas del respaldo <b>${window.ATLAS_SNAPSHOT.tables[name].total==null?"Sin snapshot":window.ATLAS_SNAPSHOT.tables[name].total.toLocaleString("es-MX")}</b></span><span>PK (campos) <b>${stats.pk}</b></span><span>FK (campos) <b>${stats.fk}</b></span><span>NOT NULL <b>${stats.notNull}</b></span></div><p class="small">Totales estructurales del Atlas. Filas y datos del respaldo histórico; las columnas pueden ser distintas. FK cuenta columnas, incluidas las claves compuestas.</p><div class="table-scroll"><table class="data-table"><thead><tr><th>Campo</th><th>Tipo</th><th>Clave</th><th>Nulo</th><th>Descripción</th></tr></thead><tbody>${t.fields.map(f=>`<tr><td><code>${esc(f.name)}</code></td><td><code>${esc(f.type)}</code></td><td>${esc(f.key)}</td><td>${esc(f.nullable)}</td><td>${esc(f.description)}</td></tr>`).join('')}</tbody></table></div>`;
  window.ATLAS_DATA_UI.mount(panel,name,category);
  const structure=panel.querySelector('.table-scroll'),fold=document.createElement('details'),summary=document.createElement('summary');fold.className='source-details';summary.textContent=`Ver los ${t.fields.length} campos del diccionario`;structure.replaceWith(fold);fold.append(summary,structure);panel.insertBefore(panel.querySelector('.atlas-rows'),fold);
  panel.hidden=false;panel.scrollTop=0;panel.querySelector('button').onclick=close;panel.querySelector('h3').focus({preventScroll:true});highlight(new Set([name]));
 }
 window.addEventListener('atlas:open-table',e=>{$('erdModule').value='';$('erdSearch').value=e.detail.table;filter(true);show(e.detail.table,e.detail.category);});
 document.addEventListener('keydown',e=>{if(e.key==='Escape'&&!panel.hidden)close();});
 entities.forEach((node,name)=>{
  node.addEventListener('pointerenter',()=>highlight(new Set([name])));node.addEventListener('pointerleave',()=>highlight(selected?new Set([selected]):new Set()));
  node.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();show(name);}});
 });
 edges.forEach(e=>{e.path.addEventListener('pointerenter',()=>highlight(new Set([e.source,e.target]),e));e.path.addEventListener('pointerleave',()=>highlight(selected?new Set([selected]):new Set()));});
 // Drag anywhere on the canvas to pan; a stationary press on a table opens it.
 viewport.style.touchAction='none';let drag=null;const pointers=new Map();let pinch=null;
 viewport.addEventListener('pointerdown',e=>{
  if(e.pointerType==='mouse'&&e.button!==0)return;
  pointers.set(e.pointerId,{x:e.clientX,y:e.clientY});viewport.setPointerCapture(e.pointerId);
  if(pointers.size===2){const [a,b]=[...pointers.values()];pinch={distance:Math.hypot(a.x-b.x,a.y-b.y),scale:getScale()};if(drag)drag.moved=true;return;}
  drag={id:e.pointerId,x:e.clientX,y:e.clientY,left:viewport.scrollLeft,top:viewport.scrollTop,moved:false,table:e.target.closest('[data-table]')?.dataset.table};e.preventDefault();viewport.classList.add('erd-panning');
 });
 function zoomAt(next,x,y){const r=viewport.getBoundingClientRect(),before=getScale(),localX=x-r.left,localY=y-r.top;setZoom(next);const ratio=getScale()/before;viewport.scrollLeft=(viewport.scrollLeft+localX)*ratio-localX;viewport.scrollTop=(viewport.scrollTop+localY)*ratio-localY;}
 viewport.addEventListener('pointermove',e=>{
  if(!pointers.has(e.pointerId))return;pointers.set(e.pointerId,{x:e.clientX,y:e.clientY});
  if(pinch&&pointers.size===2){const [a,b]=[...pointers.values()];zoomAt(pinch.scale*Math.hypot(a.x-b.x,a.y-b.y)/pinch.distance,(a.x+b.x)/2,(a.y+b.y)/2);return;}
  if(!drag||drag.id!==e.pointerId)return;const dx=e.clientX-drag.x,dy=e.clientY-drag.y;if(Math.hypot(dx,dy)>4)drag.moved=true;
  viewport.scrollLeft=drag.left-dx;viewport.scrollTop=drag.top-dy;
 });
 function release(e){pointers.delete(e.pointerId);if(viewport.hasPointerCapture(e.pointerId))viewport.releasePointerCapture(e.pointerId);if(drag&&drag.id===e.pointerId&&e.type!=='pointercancel'&&!drag.moved&&drag.table)show(drag.table);drag=null;pinch=null;viewport.classList.remove('erd-panning');}
 viewport.addEventListener('pointerup',release);viewport.addEventListener('pointercancel',release);
 viewport.addEventListener('wheel',e=>{e.preventDefault();zoomAt(getScale()*Math.exp(-e.deltaY*.0015),e.clientX,e.clientY);},{passive:false});
 viewport.addEventListener('keydown',e=>{const shifts={ArrowLeft:[-100,0],ArrowRight:[100,0],ArrowUp:[0,-100],ArrowDown:[0,100]};if(shifts[e.key]){e.preventDefault();viewport.scrollBy(...shifts[e.key]);}});
 function center(name){
  const n=entities.get(name);if(!n)return;setZoom(Math.max(.75,getScale()));
  const r=n.getBoundingClientRect(),v=viewport.getBoundingClientRect();viewport.scrollLeft+=r.left+r.width/2-v.left-v.width/2;viewport.scrollTop+=r.top+r.height/2-v.top-v.height/2;
 }
 $('erdModule').replaceChildren(new Option('Todos los módulos',''),...data.modules.map(m=>new Option(m,m)));
 function filter(recenter=false){
  query=$('erdSearch').value.toLowerCase().trim();const module=$('erdModule').value;
  const matches=tables.filter(t=>(!module||t.module===module)&&(!query||t.name.toLowerCase().includes(query)||t.fields.some(f=>f.name.toLowerCase().includes(query))));const names=new Set(matches.map(t=>t.name));
  entities.forEach((n,name)=>{n.style.opacity=names.has(name)?'':'0.8';n.style.visibility=mode==='relations'?'hidden':'';n.querySelectorAll('[data-key]').forEach(el=>{el.classList.toggle('erd-key',!!keyMode&&el.dataset.key.includes(keyMode));});});
  edges.forEach(e=>{e.path.style.opacity=names.has(e.source)&&names.has(e.target)?'':'0.8';e.path.style.visibility=mode==='tables'?'hidden':'';});
  svg.querySelectorAll('.edgeLabels,.relationshipLabel').forEach(el=>el.style.visibility=mode==='tables'?'hidden':'');
  $('erdCount').textContent=`${matches.length} de ${tables.length} tablas`;
  if(query)highlight(names);else highlight(selected?new Set([selected]):new Set());
  if(recenter&&query&&matches.length)center(matches[0].name);
 }
 $('erdSearch').addEventListener('input',()=>filter(true));$('erdModule').addEventListener('change',()=>filter());
 document.querySelectorAll('[data-erd-mode]').forEach(b=>b.addEventListener('click',()=>{mode=b.dataset.erdMode;document.querySelectorAll('[data-erd-mode]').forEach(x=>x.setAttribute('aria-pressed',String(x===b)));filter();}));
 document.querySelectorAll('[data-erd-key]').forEach(b=>b.addEventListener('click',()=>{keyMode=keyMode===b.dataset.erdKey?'':b.dataset.erdKey;document.querySelectorAll('[data-erd-key]').forEach(x=>x.setAttribute('aria-pressed',String(x.dataset.erdKey===keyMode)));filter();}));
 $('resetDiagram').addEventListener('click',()=>{setZoom(1);viewport.scrollLeft=0;viewport.scrollTop=0;$('erdSearch').value='';$('erdModule').value='';mode='all';keyMode='';panel.hidden=true;selected=null;document.querySelectorAll('[data-erd-mode]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.erdMode==='all')));document.querySelectorAll('[data-erd-key]').forEach(b=>b.setAttribute('aria-pressed','false'));filter();});
 filter();svg.setAttribute('aria-label',`ERD interactivo: ${tables.length} tablas. Arrastra para moverte, usa la rueda para zoom y pulsa una tabla para ver sus campos.`);svg.dataset.erdTables=entities.size;svg.dataset.erdRelationships=edges.length;
}
