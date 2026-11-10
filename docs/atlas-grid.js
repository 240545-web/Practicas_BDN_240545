/* Deterministic, readable SVG grid. Every label and relationship comes from Atlas data. */
function renderAtlasGrid(data,tables,colors){
 const NS='http://www.w3.org/2000/svg';const el=(tag,attrs={},text)=>{const n=document.createElementNS(NS,tag);for(const [k,v] of Object.entries(attrs))n.setAttribute(k,v);if(text!==undefined)n.textContent=text;return n;};
 const svg=el('svg',{xmlns:NS,role:'img'}),lines=el('g',{class:'edgePaths'}),nodes=el('g',{class:'nodes'}),labels=el('g',{class:'edgeLabels'});svg.append(lines,nodes,labels);
 const geometry=new Map();let y=65;const width=2340,w=420,gap=140,base=100,columns=4;
 const snapshot=window.ATLAS_SNAPSHOT;
 for(const [mi,module] of data.modules.entries()){
  svg.append(el('text',{x:base,y:y-24,fill:colors[mi],'font-size':18,'font-weight':700,'font-family':'DM Sans, sans-serif'},module));
  const group=tables.filter(t=>t.module===module);
  for(let start=0;start<group.length;start+=columns){
   const row=group.slice(start,start+columns),maxH=Math.max(...row.map(t=>80+t.fields.length*30));
   for(const [col,t] of row.entries()){
    const x=base+col*(w+gap),h=80+t.fields.length*30,box={x,y,w,h,gutter:y+maxH+40};geometry.set(t.name,box);
    const n=el('g',{class:'node','data-table':t.name,id:'entity-'+t.name,transform:`translate(${x},${y})`});
    n.append(el('rect',{width:w,height:h,rx:8,fill:'#232335',stroke:colors[mi],'stroke-width':2}));n.append(el('path',{d:`M8,0 H${w-8} Q${w},0 ${w},8 V69 H0 V8 Q0,0 8,0`,fill:'#303044'}));
    n.append(el('text',{x:16,y:26,class:'table-title',fill:'#FFFFFF','font-size':15,'font-weight':700,'font-family':'JetBrains Mono, monospace'},t.name));
    const count=snapshot?.tables[t.name]?.total;const status=count==null?'filas sin snapshot':`${count.toLocaleString('es-MX')} filas (respaldo)`;
    n.append(el('text',{x:16,y:52,fill:'#FFFFFF','font-size':12,'font-family':'DM Sans, sans-serif'},`${t.fields.length} campos | ${status}`));
    for(const [i,f] of t.fields.entries()){
     const fy=91+i*30;if(i)n.append(el('line',{x1:1,y1:fy-20,x2:w-1,y2:fy-20,stroke:'#47475f'}));
     n.append(el('text',{x:16,y:fy,class:'field-label','data-field':f.name,'data-key':f.key,fill:'#FFFFFF','font-size':13,'font-family':'JetBrains Mono, monospace'},f.name));
     n.append(el('text',{x:205,y:fy,class:'field-type',fill:'#22D3EE','font-size':12,'font-family':'JetBrains Mono, monospace'},f.type));
     if(f.key.includes('PK'))n.append(el('text',{x:363,y:fy,fill:'#FBBF24','font-size':12,'font-weight':700},'PK'));
     if(f.key.includes('FK'))n.append(el('text',{x:391,y:fy,fill:'#C4A3FF','font-size':12,'font-weight':700},'FK'));
    }
    nodes.append(n);
   }
   y+=maxH+140;
  }
  y+=65;
 }
 data.relationships.forEach((r,i)=>{
  const a=geometry.get(r.source),b=geometry.get(r.target),ay=a.y+40,by=b.y+40,sx=a.x+a.w,tx=b.x,sl=sx+35+(i%10)*4,tl=tx-35-(i%10)*4,bus=a.gutter+(i%20)*3;
  const d=`M${sx},${ay} H${sl} V${bus} H${tl} V${by} H${tx}`;
  const line=el('path',{id:`rel-entity-${r.source}-${i}-entity-${r.target}-${i}`,d,fill:'none',stroke:'#8585a3','stroke-width':1.5,class:'relationshipLine','data-relation':i,tabindex:0});line.append(el('title',{},`${r.source} → ${r.target}: ${r.fields}`));lines.append(line);
  const text=el('text',{'data-edge-label':i,x:(sl+tl)/2,y:bus-6,fill:'#FFFFFF','font-size':12,'font-family':'JetBrains Mono, monospace','text-anchor':'middle',visibility:'hidden'},r.fields);labels.append(text);
 });
 svg.setAttribute('viewBox',`0 0 ${width} ${y}`);svg.setAttribute('width',width);svg.setAttribute('height',y);return svg;
}
