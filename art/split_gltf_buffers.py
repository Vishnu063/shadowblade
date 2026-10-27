"""Repack a large static GLB into byte-identical buffer views in small external buffers."""
import json,struct,hashlib
from pathlib import Path
def split(path,limit=3000000):
 path=Path(path);data=path.read_bytes();n=struct.unpack_from('<I',data,12)[0];g=json.loads(data[20:20+n]);bin_header=20+n;blob=data[bin_header+8:]
 buffers=[bytearray()];old=[]
 for view in g['bufferViews']:
  payload=blob[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
  assert len(payload)<=limit,'Increase buffer limit for indivisible view'
  if len(buffers[-1])+len(payload)+4>limit:buffers.append(bytearray())
  target=buffers[-1]
  target.extend(b'\0'*((-len(target))%4))
  offset=len(target);target.extend(payload)
  old.append(hashlib.sha256(payload).digest())
  view['buffer']=len(buffers)-1;view['byteOffset']=offset
 g['buffers']=[]
 for i,buffer in enumerate(buffers):
  name=path.stem+'-buffer-%d.bin'%i;(path.parent/name).write_bytes(buffer)
  g['buffers'].append({'uri':name,'byteLength':len(buffer)})
 for expected,view in zip(old,g['bufferViews']):
  new=buffers[view['buffer']][view['byteOffset']:view['byteOffset']+view['byteLength']]
  assert hashlib.sha256(new).digest()==expected
 out=path.with_suffix('.gltf');out.write_text(json.dumps(g,indent=2)+'\n')
 print('Repacked %d byte-identical buffer views into %d files'%(len(old),len(buffers)))
 return out
if __name__=='__main__':
 import sys
 split(sys.argv[1])
