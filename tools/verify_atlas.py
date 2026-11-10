"""Read-only comparison of Atlas against the authoritative MySQL DDL."""
import json
import re
from pathlib import Path
root = Path(__file__).resolve().parents[1]
sql = (root / 'Practica03/ecosistema_v2/02_mysql.sql').read_text()
html = (root / 'docs/diccionario_interactivo.html').read_text()
data = json.loads(re.search(r'<script id="dictionaryData" type="application/json">(.*?)</script>', html, re.S)[1])
tables = {t['name']: t for t in data['featuredTables'] + data['additionalTables']}
source = {}
for name, body in re.findall(r'CREATE TABLE (\w+) \((.*?)\) ENGINE=InnoDB;', sql, re.S):
    source[name] = re.findall(r'^\s*`(\w+)`\s+', body, re.M)
assert set(source) == set(tables), 'Table names differ'
for name, fields in source.items():
    assert fields == [f['name'] for f in tables[name]['fields']], name
    assert re.search(r'\b' + name + r'\s*\{', data['mermaid']), name
source_triggers = re.findall(r'CREATE TRIGGER (\w+) (BEFORE|AFTER) (INSERT|UPDATE|DELETE) ON (\w+) FOR EACH ROW\s*(.*?)END\$\$', sql, re.S)
assert len(source_triggers) == len(data['triggers'])
for name, timing, event, table, body in source_triggers:
    target = next(t for t in data['triggers'] if t['name'] == name)
    assert (timing, event, table) == (target['timing'], target['event'], target['table'])
    assert body.strip() + 'END' in target['logic'], name
assert len(re.findall(r'FOREIGN KEY \([^)]+\) REFERENCES', sql)) == len(data['relationships'])
assert sum(len(t['fields']) for t in tables.values()) == sum(map(len, source.values()))
root_html = (root / 'index.html').read_text().replace('src="docs/atlas-erd.js"', 'src="atlas-erd.js"')
assert root_html == html, 'Root and docs versions differ'
print(json.dumps({'tables': len(source), 'fields': sum(map(len, source.values())), 'triggers': len(source_triggers), 'relationships': len(data['relationships']), 'result': 'COINCIDE'}, ensure_ascii=False))
