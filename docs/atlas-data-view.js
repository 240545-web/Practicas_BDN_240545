/* Historical rows are kept separate from the confirmed Atlas schema. */
function setupAtlasData({data,tables}){
 if(window.ATLAS_DATA_UI)return;
 const snapshot=window.ATLAS_SNAPSHOT;
 const esc=s=>String(s??'NULL').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 const fmt=n=>n==null?'Sin snapshot':n.toLocaleString('es-MX');
 const emit=(table,category)=>window.dispatchEvent(new CustomEvent('atlas:open-table',{detail:{table,category}}));
 const counts=t=>snapshot.tables[t.name];
 document.getElementById('atlasTotalsRows').innerHTML=tables.map(t=>{const s=counts(t),total=s.total==null?'Sin snapshot':s.total===0?'0 filas - Sin datos cargados':fmt(s.total)+' filas';return `<tr><td><button class="small-btn" data-view-atlas="${esc(t.name)}">${esc(t.name)}</button></td><td>${esc(t.module)}</td><td>${t.stats.fields}</td><td>${total}</td><td>${t.stats.pk}</td><td>${t.stats.fk}</td><td>${esc(s.example||'Sin dato disponible')}</td></tr>`;}).join('');
 const groups=[...snapshot.categories,{id:'unassigned',name:'Sin categoría asignada',total:snapshot.unassigned,example:snapshot.tables.tb_products.rows.find(r=>r[snapshot.tables.tb_products.columns.indexOf('category_id')]==null)?.[snapshot.tables.tb_products.columns.indexOf('name')]||null}];
 if(snapshot.orphans)groups.push({id:'orphan',name:'Referencia a categoría inexistente',total:snapshot.orphans});
 document.getElementById('categoryReconcile').textContent=`Respaldo: ${fmt(snapshot.productsTotal)} productos = ${fmt(snapshot.productsTotal-snapshot.unassigned-snapshot.orphans)} clasificados + ${fmt(snapshot.unassigned)} sin categoría + ${fmt(snapshot.orphans)} referencias inexistentes. Diferencia con la referencia de 5.000: ${(snapshot.productsTotal-5000).toLocaleString('es-MX')}. No falta una categoría: hay productos sin asignar y el respaldo tiene más productos.`;
 document.getElementById('atlasCategoryRows').innerHTML=groups.map(c=>`<tr><td><button class="small-btn" data-category="${esc(c.id)}">${esc(c.name)}</button></td><td>${fmt(c.total)}</td><td>${(c.total/snapshot.productsTotal*100).toFixed(2)} %</td><td>${esc(c.example||'Sin productos')}</td><td><div class="category-bar" role="img" aria-label="${esc(c.name)}: ${c.total} productos"><span style="width:${c.total/snapshot.productsTotal*100}%"></span></div></td></tr>`).join('')+`<tr><td><strong>Total del respaldo</strong></td><td><strong>${fmt(snapshot.productsTotal)}</strong></td><td>100 %</td><td colspan="2">Referencia solicitada: 5.000; no coincide con el respaldo.</td></tr>`;
 document.addEventListener('click',e=>{const view=e.target.closest('[data-view-atlas]');if(view){location.hash='/erd';emit(view.dataset.viewAtlas);}const cat=e.target.closest('[data-category]');if(cat){location.hash='/erd';emit('tb_products',cat.dataset.category);}});
 function mount(parent,name,category){
  const s=snapshot.tables[name],wrap=document.createElement('section');wrap.className='atlas-rows';parent.append(wrap);
  const isProducts=name==='tb_products',isCategories=name==='tb_categories';
  wrap.innerHTML=`<h3>Datos de ${esc(name)}</h3><p class="data-warning">${s.status==='unavailable'?'Esta tabla no existe en el respaldo. No hay filas verificables; esto no equivale a cero.':`Respaldo del ${esc(snapshot.snapshotDate)}. ${s.schemaMatchesAtlas?'Columnas compatibles.':'Esquema histórico distinto: las columnas de abajo son las reales del respaldo, no una migración al Atlas.'} Credenciales ocultas.`}</p><div class="data-controls"><input type="search" class="row-search" placeholder="Buscar dentro de ${esc(name)}…" aria-label="Buscar datos en ${esc(name)}">${isProducts?`<select class="category-select" aria-label="Filtrar productos por categoría"><option value="">Todas las categorías</option>${groups.map(c=>`<option value="${esc(c.id)}">${esc(c.name)}</option>`).join('')}</select>`:''}</div><p class="row-status" role="status" aria-live="polite"></p><div class="atlas-data-wrap"><table class="data-table"><thead><tr>${s.columns.map(c=>`<th>${esc(c)}</th>`).join('')}${isCategories?'<th>Total productos</th><th>Ver productos</th>':''}</tr></thead><tbody class="row-values"></tbody></table></div><div class="data-pager"><button class="small-btn prev">Anterior</button><span class="page-status"></span><button class="small-btn next">Siguiente</button></div>`;
  const search=wrap.querySelector('input'),select=wrap.querySelector('select');let page=0;
  if(select&&category!=null)select.value=String(category);
  const names=s.columns,categoryIndex=names.indexOf('category_id'),known=new Set(snapshot.categories.map(c=>String(c.id)));
  const indexed=s.rows.map(r=>({r,key:r.join(' ').toLocaleLowerCase('es')}));
  function render(){
   const q=search.value.trim().toLocaleLowerCase('es'),cat=select?.value||'';
   const rows=indexed.filter(({r,key})=>(!q||key.includes(q))&&(!cat||(cat==='unassigned'?r[categoryIndex]==null:cat==='orphan'?r[categoryIndex]!=null&&!known.has(String(r[categoryIndex])):String(r[categoryIndex])===cat))).map(x=>x.r);
   const pages=Math.max(1,Math.ceil(rows.length/10));page=Math.min(page,pages-1);const start=page*10,end=Math.min(start+10,rows.length);
   wrap.querySelector('.row-values').innerHTML=rows.slice(start,end).map(r=>{const categoryId=isCategories?r[names.indexOf('ID')]:null,c=snapshot.categories.find(c=>String(c.id)===String(categoryId));return '<tr>'+r.map(v=>`<td class="data-cell">${esc(v)}</td>`).join('')+(isCategories?`<td>${c?.total??0}</td><td><button class="small-btn" data-category="${esc(categoryId)}">Ver productos</button></td>`:'')+'</tr>';}).join('')||`<tr><td colspan="${names.length+(isCategories?2:0)}">${s.status==='unavailable'?'No hay snapshot de esta tabla.':'Sin resultados.'}</td></tr>`;
   wrap.querySelector('.page-status').textContent=s.status==='unavailable'?'Sin snapshot: paginación no disponible':`Mostrando ${rows.length?start+1:0}-${end} de ${rows.length} filas`;
   wrap.querySelector('.row-status').textContent=s.status==='unavailable'?'Total filas: sin snapshot':`Mostrando ${fmt(rows.length)} de ${fmt(s.rows.length)} ${isProducts?'productos':'filas'}${cat?' - Categoría: '+(groups.find(c=>String(c.id)===cat)?.name||cat):''}`;
   wrap.querySelector('.prev').disabled=page===0;wrap.querySelector('.next').disabled=page>=pages-1;
  }
  search.oninput=()=>{page=0;render();};if(select)select.onchange=()=>{page=0;render();};wrap.querySelector('.prev').onclick=()=>{page--;render();};wrap.querySelector('.next').onclick=()=>{page++;render();};render();
 }
 window.ATLAS_DATA_UI={mount,open:emit};
}
