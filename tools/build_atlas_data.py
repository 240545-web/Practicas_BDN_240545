"""Extract a static, credential-redacted snapshot without executing SQL."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SOURCE='Practica03/backups/respaldo_final_240545.sql'
sql=(ROOT/SOURCE).read_text()

def scalar(raw):
    raw=raw.strip()
    if raw.upper()=='NULL': return None
    binary=raw.startswith('_binary ')
    if binary: raw=raw[8:].strip()
    if raw.startswith("'") and raw.endswith("'"):
        v=raw[1:-1];v=re.sub(r"\\(.)",lambda m:{'0':'\0','n':'\n','r':'\r','t':'\t','Z':'\x1a'}.get(m[1],m[1]),v,flags=re.S).replace("''", "'")
        return ord(v) if binary and len(v)==1 else v
    try: return float(raw) if '.' in raw else int(raw)
    except ValueError: raise ValueError('Unsupported SQL literal')

def tuples(text):
    rows=[];vals=[];start=0;depth=0;quoted=False;i=0
    while i<len(text):
        c=text[i]
        if quoted:
            if c=='\\': i+=2;continue
            if c=="'":
                if i+1<len(text) and text[i+1]=="'":i+=2;continue
                quoted=False
        elif c=="'":quoted=True
        elif c=='(':
            if depth==0: start=i+1;vals=[]
            depth+=1
        elif c==',' and depth==1: vals.append(scalar(text[start:i]));start=i+1
        elif c==')':
            depth-=1
            if depth==0:vals.append(scalar(text[start:i]));rows.append(vals)
        i+=1
    assert not quoted and depth==0
    return rows

snapshot={}
for name,body in re.findall(r'CREATE TABLE `(\w+)` \((.*?)\) ENGINE=',sql,re.S):
    columns=re.findall(r'^\s*`(\w+)`\s+',body,re.M)
    snapshot[name]={'columns':columns,'rows':[],'source':SOURCE,'status':'snapshot','schemaMatchesAtlas':False}
for line in sql.splitlines():
    m=re.match(r'INSERT INTO `(\w+)` VALUES (.*);$',line)
    if not m:continue
    name,values=m.groups();rows=tuples(values)
    for row in rows:
        assert len(row)==len(snapshot[name]['columns']),name
        for i,c in enumerate(snapshot[name]['columns']):
            if re.search(r'password|passwd|secret|token',c,re.I):row[i]='[Oculto]'
    snapshot[name]['rows'].extend(rows)
html=(ROOT/'index.html').read_text();data=json.loads(re.search(r'<script id="dictionaryData" type="application/json">(.*?)</script>',html,re.S)[1]);tables=data['featuredTables']+data['additionalTables']
for t in tables:
    if t['name'] not in snapshot:snapshot[t['name']]={'columns':[f['name'] for f in t['fields']],'rows':[],'source':None,'status':'unavailable','schemaMatchesAtlas':False}
    s=snapshot[t['name']];s['schemaMatchesAtlas']=s['columns']==[f['name'] for f in t['fields']]
    s['total']=len(s['rows']) if s['status']=='snapshot' else None
    s['example']=next((str(row[s['columns'].index(key)]) for row in s['rows'] for key in ['name','nickname','given_names','email','code','ID'] if key in s['columns'] and row[s['columns'].index(key)] is not None),None)
products=snapshot['tb_products'];categories=snapshot['tb_categories']
def objects(t):return [dict(zip(t['columns'],r)) for r in t['rows']]
ps=objects(products);cs=objects(categories);known={str(c['ID']) for c in cs};groups=[]
for c in cs:
    matches=[p for p in ps if str(p.get('category_id'))==str(c['ID'])]
    groups.append({'id':c['ID'],'name':c['name'],'total':len(matches),'example':next((p['name'] for p in matches),None)})
unassigned=[p for p in ps if p.get('category_id') is None];orphans=[p for p in ps if p.get('category_id') is not None and str(p['category_id']) not in known]
assert sum(g['total'] for g in groups)+len(unassigned)+len(orphans)==len(ps)
output={'source':SOURCE,'snapshotDate':re.search(r'Dump completed on (.*)',sql)[1] if re.search(r'Dump completed on (.*)',sql) else '2026-10-25 (commit)','schemaSource':'Practica03/ecosistema_v2/02_mysql.sql','tables':snapshot,'categories':groups,'productsTotal':len(ps),'unassigned':len(unassigned),'orphans':len(orphans),'reference':{'products':5000,'users':10222},'note':'Respaldo histórico de 18 tablas. Sus columnas y filas no son un snapshot del esquema Atlas de 26 tablas. No se suman versiones ni se inventan filas.'}
(ROOT/'docs/data.js').write_text('window.ATLAS_SNAPSHOT = '+json.dumps(output,ensure_ascii=False,separators=(',',':')).replace('</','<\\/')+';\n')
report={'source':SOURCE,'snapshotDate':output['snapshotDate'],'tables':[{'table':t['name'],'module':t['module'],**t['stats'],'snapshotRows':snapshot[t['name']]['total'],'example':snapshot[t['name']]['example'],'schemaMatchesAtlas':snapshot[t['name']]['schemaMatchesAtlas']} for t in tables],'categories':groups,'productsTotal':len(ps),'unassigned':len(unassigned),'orphans':len(orphans)}
(ROOT/'docs/data-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'snapshotTables':len([s for s in snapshot.values() if s['status']=='snapshot']),'rows':{k:len(v['rows']) for k,v in snapshot.items() if v['status']=='snapshot'},'categories':groups,'unassigned':len(unassigned),'orphans':len(orphans)},ensure_ascii=False))
