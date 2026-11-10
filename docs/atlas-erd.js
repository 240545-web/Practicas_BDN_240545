/* Atlas ERD: preserve Mermaid's LR placement and the existing Atlas shell. */
function enhanceAtlasERD({svg,data,tables,colors,setZoom,getScale,openTable}) {
 const $=id=>document.getElementById(id), NS='http://www.w3.org/2000/svg';
 const entities=new Map();
 for(const table of tables){
  const node=[...svg.querySelectorAll('g.node, g[id^="entity-"]')].find(n=>n.id.includes('entity-'+table.name+'-') || [...n.querySelectorAll('text,tspan,.nodeLabel')].some(t=>t.textContent.trim()===table.name));
  if(!node)throw new Error('Tabla ausente del SVG: '+table.name);
  entities.set(table.name,node);node.dataset.table=table.name;node.setAttribute('tabindex','0');node.setAttribute('role','button');node.setAttribute('aria-label','Abrir '+table.name);
  const color=colors[data.modules.indexOf(table.module)];
  node.querySelectorAll('rect').forEach((r,i)=>{r.style.stroke=color;r.style.fill=i%2?'#28283b':'#232335';});node.querySelectorAll('text,tspan').forEach(t=>{t.style.fill='#e8e6f5';});
 }
 const edgePaths=[...svg.querySelectorAll('path.relationshipLine, .edgePaths path')];
 const edges=data.relationships.map((rel,i)=>{
  const exact=edgePaths.find(p=>p.id.includes(rel.source)&&p.id.includes(rel.target)&&!p.dataset.bound);
  const path=exact||edgePaths[i];if(path)path.dataset.bound='true';
  return {...rel,path};
 });
 function focus(name){
  const related=new Set([name]);edges.forEach(e=>{if(e.source===name||e.target===name){related.add(e.source);related.add(e.target);}});
  entities.forEach((n,key)=>{n.classList.toggle('erd-muted',!!name&&!related.has(key));n.classList.toggle('erd-active',key===name);});
  edges.forEach(e=>{if(e.path)e.path.classList.toggle('erd-muted',!!name&&e.source!==name&&e.target!==name);});
 }
 const original=new Map();entities.forEach((n,key)=>original.set(key,n.getAttribute('transform')||''));
 const offsets=new Map(tables.map(t=>[t.name,{x:0,y:0}]));
 function center(node){const box=node.getBBox(),m=node.getCTM(),parent=svg.getCTM().inverse();const point=new DOMPoint(box.x+box.width/2,box.y+box.height/2).matrixTransform(m).matrixTransform(parent);return {x:point.x,y:point.y,w:box.width,h:box.height};}
 function reroute(name){
  edges.filter(e=>e.source===name||e.target===name).forEach(e=>{
   if(!e.path)return;
   const a=center(entities.get(e.source)),b=center(entities.get(e.target));
   const right=b.x>=a.x,ax=a.x+(right?1:-1)*a.w/2,bx=b.x-(right?1:-1)*b.w/2;
   const parent=e.path.parentElement.getCTM().inverse(),root=svg.getCTM();
   const p=new DOMPoint(ax,a.y).matrixTransform(root).matrixTransform(parent),q=new DOMPoint(bx,b.y).matrixTransform(root).matrixTransform(parent),mid=(p.x+q.x)/2;
   e.path.setAttribute('d',`M${p.x},${p.y} C${mid},${p.y} ${mid},${q.y} ${q.x},${q.y}`);
  });
 }
 function grow(){const b=svg.getBBox(),v=svg.viewBox.baseVal;const left=Math.min(v.x,b.x-30),top=Math.min(v.y,b.y-30);svg.setAttribute('viewBox',`${left} ${top} ${Math.max(v.x+v.width,b.x+b.width+30)-left} ${Math.max(v.y+v.height,b.y+b.height+30)-top}`);}
 entities.forEach((node,name)=>{
  let drag=null,moved=false;
  node.addEventListener('pointerenter',()=>{if(!drag)focus(name);});node.addEventListener('pointerleave',()=>{if(!drag)focus(null);});
  node.addEventListener('focus',()=>focus(name));node.addEventListener('blur',()=>focus(null));
  node.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();openTable(name);}});
  node.addEventListener('pointerdown',e=>{if(e.button!==0)return;const p=new DOMPoint(e.clientX,e.clientY).matrixTransform(node.parentElement.getScreenCTM().inverse());drag={p,offset:{...offsets.get(name)},x:e.clientX,y:e.clientY};moved=false;node.setPointerCapture(e.pointerId);e.preventDefault();});
  node.addEventListener('pointermove',e=>{if(!drag)return;if(Math.hypot(e.clientX-drag.x,e.clientY-drag.y)>4)moved=true;if(!moved)return;const p=new DOMPoint(e.clientX,e.clientY).matrixTransform(node.parentElement.getScreenCTM().inverse()),o={x:drag.offset.x+p.x-drag.p.x,y:drag.offset.y+p.y-drag.p.y};offsets.set(name,o);node.setAttribute('transform',`translate(${o.x},${o.y}) ${original.get(name)}`);reroute(name);});
  node.addEventListener('pointerup',e=>{if(!drag)return;drag=null;if(node.hasPointerCapture(e.pointerId))node.releasePointerCapture(e.pointerId);if(moved)grow();else openTable(name);});
  node.addEventListener('pointercancel',()=>{drag=null;focus(null);});
 });
 $('erdModule').replaceChildren(new Option('Todos los módulos',''),...data.modules.map(m=>new Option(m,m)));
 function filter(){const query=$('erdSearch').value.toLowerCase().trim(),module=$('erdModule').value;const visible=new Set(tables.filter(t=>(!module||t.module===module)&&t.name.toLowerCase().includes(query)).map(t=>t.name));entities.forEach((n,key)=>{n.style.opacity=visible.has(key)?'':'0.12';});edges.forEach(e=>{if(e.path)e.path.style.opacity=visible.has(e.source)&&visible.has(e.target)?'':'0.08';});$('erdCount').textContent=`${visible.size} de ${tables.length} tablas`;}
 $('erdSearch').addEventListener('input',filter);$('erdModule').addEventListener('change',filter);filter();
 $('diagramViewport').addEventListener('wheel',e=>{e.preventDefault();const v=$('diagramViewport'),before=getScale(),x=e.clientX-v.getBoundingClientRect().left,y=e.clientY-v.getBoundingClientRect().top;setZoom(before*Math.exp(-e.deltaY*.0015));const ratio=getScale()/before;v.scrollLeft=(v.scrollLeft+x)*ratio-x;v.scrollTop=(v.scrollTop+y)*ratio-y;},{passive:false});
 svg.setAttribute('aria-label',`Modelo relacional: ${tables.length} tablas, ${data.relationships.length} relaciones. Arrastra tablas para moverlas; pulsa para abrir su detalle.`);
 svg.dataset.erdTables=entities.size;svg.dataset.erdRelationships=edges.length;
}
