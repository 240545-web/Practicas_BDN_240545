"""Validate snapshot reconciliation, redaction and the static extraction artifact."""
import json,re,subprocess,sys
from pathlib import Path
r=Path(__file__).resolve().parents[1]
asset=r/'docs/data.js';before=asset.read_bytes()
subprocess.run([sys.executable,str(r/'tools/build_atlas_data.py')],check=True,capture_output=True)
assert asset.read_bytes()==before,'Data artifact is not reproducible from the SQL dump'
s=json.loads(asset.read_text().removeprefix('window.ATLAS_SNAPSHOT = ').strip().removesuffix(';'))
assert s['productsTotal']==len(s['tables']['tb_products']['rows'])
assert sum(c['total'] for c in s['categories'])+s['unassigned']+s['orphans']==s['productsTotal']
assert len({c['id'] for c in s['categories']})==len(s['tables']['tb_categories']['rows'])
for name,t in s['tables'].items():
    if 'total' in t:assert t['total']==(len(t['rows']) if t['status']=='snapshot' else None),name
    for row in t['rows']:
        assert len(row)==len(t['columns']),name
        for i,c in enumerate(t['columns']):
            if re.search(r'password|passwd|secret|token',c,re.I):assert row[i]=='[Oculto]'
for name in ['tb_products','tb_users','tb_categories']:
    t=s['tables'][name]; idx=t['columns'].index('ID'); assert len({row[idx] for row in t['rows']})==len(t['rows']), name
assert s['reference']['products']!=s['productsTotal'],'Reference must not be silently treated as snapshot count'
print('PASS: reproducible rows, SQL column counts, all categories, unassigned products, unknown vs zero, credential redaction')
