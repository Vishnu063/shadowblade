"""Read generated alpha sheets and write part-extraction metadata. Source PNGs stay intact."""
from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage
ROOT=Path(__file__).resolve().parents[1]
for name,rows in [('kael',4)]+[(name,3) for name in ['warden','cinder','frost','gale','tempest','void']]:
 p=ROOT/'assets/image_characters'/f'{name}-parts.png'
 a=np.asarray(Image.open(p))[:,:,3];h,w=a.shape
 labels,count=ndimage.label(a>32);slices=ndimage.find_objects(labels);sizes=np.bincount(labels.ravel());chosen={}
 for i,region in enumerate(slices,1):
  if region is None or sizes[i]<1000:continue
  x0,x1=region[1].start,region[1].stop;y0,y1=region[0].start,region[0].stop
  index=min(rows-1,int((y0+y1)*.5/h*rows))*4+min(3,int((x0+x1)*.5/w*4))
  if index not in chosen or sizes[i]>sizes[chosen[index][0]]:chosen[index]=(i,region)
 assert len(chosen)==rows*4,(name,chosen.keys())
 parts=[]
 for index in range(rows*4):
  label,region=chosen[index];mask=labels==label
  yy,xx=np.mgrid[:h,:w];rx=(xx-region[1].start)/max(1,region[1].stop-region[1].start);ry=(yy-region[0].start)/max(1,region[0].stop-region[0].start)
  if name=='kael':
   if index==1:
    low=np.interp(ry,[0,.15,.45,.66,.82],[.36,.30,.32,.34,.27]);high=np.interp(ry,[0,.15,.45,.66,.82],[.70,.79,.77,.75,.88]);mask &= (rx>=low)&(rx<=high)&(ry<=.82)
   if index==2:mask &= ry<=.44
   if index==8:mask &= rx>=.42
   if index==10:mask &= rx<=.59
  mask=ndimage.binary_dilation(mask,iterations=2)&(a>0)
  ys,xs=np.nonzero(mask);x0,x1=int(xs.min()),int(xs.max()+1);y0,y1=int(ys.min()),int(ys.max()+1)
  local=mask[y0:y1,x0:x1];runs=[]
  for row,line in enumerate(local):
   edges=np.flatnonzero(np.diff(np.r_[False,line,False].astype(np.int8)))
   for left,right in zip(edges[::2],edges[1::2]):runs.append([row,int(left),int(right-left)])
  parts.append({'rect':[x0,y0,x1-x0,y1-y0],'runs':runs})
 out={'source':p.name,'size':[w,h],'parts':parts,'note':'Runtime masks only isolate disconnected atlas parts; generated source pixels are unchanged.'}
 p.with_suffix('.json').write_text(json.dumps(out,separators=(',',':'))+'\n')
 print(name,len(parts),'parts',sum(len(x['runs']) for x in parts),'alpha runs')
