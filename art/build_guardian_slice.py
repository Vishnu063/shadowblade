"""Original 3D vertical-slice artwork with adapted CC0 MakeHuman head topology. Blender 4.2+.
Build: blender -b --python art/build_guardian_slice.py
Human mesh has an actual weighted armature. Warden uses articulated wood joints.
"""
from pathlib import Path
import math, random, json
import bpy
from mathutils import Vector
source=Path(__file__).with_name('forest_blender.py')
exec(compile(source.read_text().split("scene('Kael')")[0],str(source),'exec'))
OUT=ROOT/'assets/slice3d'; OUT.mkdir(exist_ok=True)
random.seed(8127)
# Original colour/normal/roughness maps. Pigment variation and fine surface relief.
def surface(name,base,kind,rough=.7,metal=0):
 import numpy as np
 m=mat(name,base,rough,metal)
 n=512; y,x=np.mgrid[0:n,0:n];rng=np.random.default_rng(sum(map(ord,name)))
 grain=rng.random((n,n))-.5
 if kind=='cloth': f=.92+.045*np.sin(x*math.pi)+.045*np.cos(y*math.pi)+grain*.12;h=np.sin(x*math.pi)*np.cos(y*math.pi)*.12+grain*.04
 elif kind=='bark': f=.8+.12*np.sin(x*.13+np.sin(y*.025)*2)+.08*np.sin(x*.39+y*.008)+grain*.1;h=np.sin(x*.13+np.sin(y*.025)*2)*.32+grain*.07
 elif kind=='stone':
  frequencies=np.fft.fftfreq(n)[:,None]**2+np.fft.rfftfreq(n)[None,:]**2
  coarse=np.fft.irfft2(np.fft.rfft2(grain)*np.exp(-frequencies*430),s=(n,n));coarse/=max(.001,coarse.std()*3)
  f=.85+coarse*.12+grain*.09;h=coarse*.07+grain*.02
 elif kind=='metal': f=.9+grain*.08+.06*np.sin(y*.35);h=grain*.012
 else:f=.86+grain*.17+.04*np.sin(x*.12)*np.cos(y*.15);h=grain*.055
 for suffix,array in [('albedo',np.stack([np.clip(base[i]*f,0,1) for i in range(3)]+[np.ones_like(f)],axis=2)),('normal',None),('roughness',None)]:
  if suffix=='normal':
   dy,dx=np.gradient(h); array=np.stack([.5-dx,.5-dy,np.ones_like(h),np.ones_like(h)],axis=2)
  if suffix=='roughness':array=np.stack([np.clip(rough+grain*.12,0,1)]*3+[np.ones_like(h)],axis=2)
  im=bpy.data.images.new(name+' '+suffix,width=n,height=n);im.pixels.foreach_set(array.astype('float32').ravel());im.pack()
  tex=m.node_tree.nodes.new('ShaderNodeTexImage');tex.image=im
  bs=m.node_tree.nodes.get('Principled BSDF')
  if suffix=='albedo':m.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
  elif suffix=='normal':
   im.colorspace_settings.name='Non-Color';norm=m.node_tree.nodes.new('ShaderNodeNormalMap');m.node_tree.links.new(tex.outputs['Color'],norm.inputs['Color']);m.node_tree.links.new(norm.outputs['Normal'],bs.inputs['Normal'])
  else:im.colorspace_settings.name='Non-Color';m.node_tree.links.new(tex.outputs['Color'],bs.inputs['Roughness'])
 return m
navy=surface('Midnight woven wool',(.022,.055,.13),'cloth',.79)
linen=surface('Warm linen',(.57,.51,.39),'cloth',.85)
hide=surface('Chestnut worn leather',(.16,.066,.027),'leather',.55)
trouser=surface('Charcoal weave',(.035,.042,.05),'cloth',.84)
silver=surface('Brushed guardian steel',(.31,.37,.43),'metal',.32,.72)
bronze=surface('Engraved warm brass',(.43,.25,.075),'metal',.37,.7)
scarfblue=surface('Royal cobalt silk',(.018,.10,.34),'cloth',.56)
skinmat=mat('Skin warm complexion',(.42,.245,.17),.72)
lip=mat('Natural lip',(.32,.13,.10),.8);hairmat=mat('Dark swept hair',(.012,.009,.008),.86)
hairlight=mat('Hair edge warm',(.036,.022,.015),.52)
iris=mat('Blue hazel iris',(.08,.16,.18),.35);pupil=mat('Pupil',(.004,.007,.01),.25)
bluegem=mat('Arcane sapphire',(.015,.31,.68),.23,.25,.8)
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
scene('Kael weighted guardian')
# Rest skeleton in project Y-up coordinates, converted for Blender.
bones={
 'Hips':((0,.97,0),(0,1.10,0),None), 'Spine':((0,1.10,0),(0,1.32,0),'Hips'),
 'Chest':((0,1.32,0),(0,1.49,0),'Spine'),'Head':((0,1.49,0),(0,1.78,0),'Chest'),
 'Scarf':((-.06,1.52,-.02),(-.42,1.5,-.05),'Chest'),
 'ScarfTip':((-.42,1.5,-.05),(-.85,1.40,-.04),'Scarf'),
 'CoatL':((-.12,1.0,-.01),(-.20,.66,-.01),'Hips'), 'CoatR':((.12,1.0,-.01),(.20,.66,-.01),'Hips')}
for side,tag in [(-1,'L'),(1,'R')]:
 bones['Thigh'+tag]=((side*.105,.97,0),(side*.12,.55,.01),'Hips')
 bones['Shin'+tag]=((side*.12,.55,.01),(side*.12,.14,.01),'Thigh'+tag)
 bones['Foot'+tag]=((side*.12,.14,.01),(side*.12,.10,.18),'Shin'+tag)
 bones['Arm'+tag]=((side*.235,1.44,0),(side*.29,1.17,.01),'Chest')
 bones['Forearm'+tag]=((side*.29,1.17,.01),(side*.325,.94,.045),'Arm'+tag)
 bones['Hand'+tag]=((side*.325,.94,.045),(side*.33,.87,.045),'Forearm'+tag)
bones['Sword']=((.33,.9,.07),(.55,.9,.07),'HandR')
rig_data=bpy.data.armatures.new('Kael skeleton');rig=bpy.data.objects.new('KaelRig',rig_data);bpy.context.scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
for name,(a,b,parent) in bones.items():
 bone=rig_data.edit_bones.new(name);bone.head=V(a);bone.tail=V(b)
 if parent:bone.parent=rig_data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT');rig.select_set(False)
def bind(o,bone):
 o.parent=rig
 vg=o.vertex_groups.new(name=bone);vg.add(list(range(len(o.data.vertices))),1,'REPLACE')
 mod=o.modifiers.new('Weighted deformation','ARMATURE');mod.object=rig
 return o
def E(name,p,size,m,bone='Hips'):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16)
 return bind(finish(bpy.context.object,name,p,size,m),bone)
def T(name,pts,rads,m,bone='Hips',sides=12):return bind(tube(name,pts,rads,m,sides=sides),bone)
def C(name,p,size,m,bone='Hips',bevel=.015):return bind(cube(name,p,size,m,bevel=bevel),bone)
def mesh(name,verts,faces,m,bone=None):
 me=bpy.data.meshes.new(name);me.from_pydata([V(v) for v in verts],[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.scene.collection.objects.link(o);o.data.materials.append(m)
 for f in me.polygons:f.use_smooth=True
 if bone:bind(o,bone)
 return o
def rings(name,rows,m,bone):
 n=40;verts=[];faces=[]
 for y,w,d,z in rows:
  for i in range(n):
   a=i*math.tau/n;verts.append((math.cos(a)*w,y,math.sin(a)*d+z))
 for j in range(len(rows)-1):
  for i in range(n):a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
 faces += [tuple(reversed(range(n))),tuple((len(rows)-1)*n+i for i in range(n))]
 return mesh(name,verts,faces,m,bone)
# Continuous tailored torso, with smoothly blended spine/chest influence.
body=rings('Tailored guardian coat',[(.96,.155,.11,0),(1.04,.16,.105,0),(1.17,.165,.11,0),(1.31,.205,.12,0),(1.43,.235,.105,-.005),(1.49,.11,.075,0)],navy,'Spine')
vg=body.vertex_groups.new(name='Chest')
for v in body.data.vertices:
 y=v.co.z;w=max(0,min(1,(y-1.23)/.2));vg.add([v.index],w,'REPLACE');body.vertex_groups['Spine'].add([v.index],1-w,'REPLACE')
# Cream waistcoat inset and sewn leather border.
mesh('Linen waistcoat front',[(-.06,1.02,.115),(.06,1.02,.115),(.075,1.4,.105),(-.075,1.4,.105)],[(0,1,2,3)],linen,'Spine')
for side in [-1,1]:
 T('Tailored lapel',[(side*.075,1.42,.105),(side*.052,1.25,.126),(side*.046,1.06,.116)],[.012,.009,.008],bronze,'Chest',8)
 for y in [1.1,1.19,1.28,1.37]:E('Waistcoat fastener',(side*.022,y,.124),(.004,.005,.004),bronze,'Spine')
# Four sculpted cloth panels, fold ridges and gold hems; weighted to coat bones.
for side,tag in [(-1,'L'),(1,'R')]:
 for back in [False,True]:
  verts=[];faces=[]
  for row in range(9):
   t=row/8;y=1.0-t*(.46 if back else .38)
   for j in range(7):
    u=j/6;x=side*(.045+u*.18+t*.055);z=(-.11 if back else .12)+math.sin(u*math.pi*3)*.008+t*.025*math.sin(u*5)
    verts.append((x,y,z))
  for row in range(8):
   for j in range(6):a=row*7+j;faces.append((a,a+1,a+8,a+7))
  mesh('Split coat tail',verts,faces,navy,'Coat'+tag)
  T('Coat brass hem',[verts[56+j] for j in range(7)],[.005]*7,bronze,'Coat'+tag,7)
  for j in [0,6]:T('Coat edge',[verts[row*7+j] for row in range(9)],[.004]*9,bronze,'Coat'+tag,7)
# Double belt, diagonal strap and actual buckle/loops.
rings('Waist leather belt',[(.988,.172,.128,0),(1.055,.172,.128,0)],hide,'Hips')
C('Buckle rim',(0,1.02,.14),(.076,.058,.018),bronze,bevel=.008)
C('Buckle inset',(0,1.02,.152),(.046,.032,.007),hide,bevel=.003)
T('Buckle tongue',[(-.023,1.02,.16),(.024,1.02,.16)],[.004,.004],bronze,sides=7)
strap=C('Cross body sword strap',(-.045,1.27,.125),(.035,.39,.018),hide,'Chest',.006);strap.rotation_euler.y=.36
for side in [-1,1]:
 E('Hip satchel',(side*.19,1.0,-.025),(.053,.079,.055),hide)
 C('Satchel flap',(side*.19,1.025,.024),(.10,.05,.015),hide,bevel=.01)
 E('Satchel clasp',(side*.19,1.02,.035),(.008,.008,.006),bronze)
# Legs, boot construction and layered greaves.
for side,tag in [(-1,'L'),(1,'R')]:
 thigh='Thigh'+tag;shin='Shin'+tag;foot='Foot'+tag
 T('Trouser thigh',[(side*.105,.97,0),(side*.115,.78,0),(side*.12,.55,.01)],[.088,.078,.057],trouser,thigh,20)
 T('Knee cloth',[(side*.12,.59,.01),(side*.12,.5,.01)],[.06,.058],trouser,shin,18)
 T('Boot shaft',[(side*.12,.50,.01),(side*.12,.36,.012),(side*.12,.15,.02)],[.072,.064,.049],hide,shin,20)
 E('Sculpted boot',(side*.12,.105,.073),(.071,.095,.14),hide,foot)
 C('Boot sole',(side*.12,.025,.08),(.15,.035,.25),hide,foot,.018)
 for y in [.19,.30,.41]:
  T('Boot strap',[(side*.12-.062,y,.048),(side*.12,y-.012,.078),(side*.12+.062,y,.048)],[.012]*3,hide,shin,8)
  C('Boot strap buckle',(side*.12+.045,y,.076),(.026,.027,.013),bronze,shin,.004)
 # Curved pointed knee and shin plate rather than blocks.
 verts=[(side*.12-.057,.59,.064),(side*.12+.057,.59,.064),(side*.12+.047,.49,.085),(side*.12,.46,.11),(side*.12-.047,.49,.085),(side*.12,.55,.119)]
 mesh('Knee shield',verts,[(0,1,5),(1,2,5),(2,3,5),(3,4,5),(4,0,5)],silver,shin)
 T('Knee embossed ridge',[(side*.12,.58,.123),(side*.12,.5,.125),(side*.12,.46,.113)],[.004]*3,bronze,shin,7)
 T('Greave ridge',[(side*.12,.43,.079),(side*.12,.32,.097),(side*.12,.19,.075)],[.024,.035,.013],silver,shin,8)
 for y in [.75,.8,.86]:T('Trouser fold',[(side*.12-.04,y,.06),(side*.12,y-.012,.079),(side*.12+.04,y,.06)],[.004]*3,trouser,thigh,6)
# Anatomical arms: sleeve rings blended across the elbow, bracers and individual fingers.
for side,tag in [(-1,'L'),(1,'R')]:
 arm='Arm'+tag;fore='Forearm'+tag;hand='Hand'+tag
 sleeve=T('Linen sleeve',[(side*.235,1.44,0),(side*.265,1.35,0),(side*.29,1.18,.01),(side*.31,1.07,.024)],[.075,.078,.051,.045],linen,arm,24)
 fg=sleeve.vertex_groups.new(name=fore)
 for v in sleeve.data.vertices:
  # tube vertices are already in global authoring coordinates.
  w=max(0,min(1,(1.24-v.co.z)/.12));fg.add([v.index],w,'REPLACE');sleeve.vertex_groups[arm].add([v.index],1-w,'REPLACE')
 T('Leather gauntlet',[(side*.305,1.115,.02),(side*.32,.98,.04)],[.056,.046],hide,fore,20)
 # Front plated bracer, narrow engraved ribs.
 for j in range(3):
  T('Overlapping bracer plate',[(side*.31,1.105-j*.035,.066),(side*.33,1.065-j*.035,.084)],[.035,.027],silver,fore,10)
 E('Bracer sapphire',(side*.32,1.055,.104),(.012,.023,.008),bluegem,fore)
 E('Leather glove palm',(side*.325,.925,.049),(.038,.055,.027),hide,hand)
 for finger in range(4):
  x=side*(.302+finger*.014)
  T('Glove finger',[(x,.902,.058),(x+side*.003,.872,.065),(x+side*.005,.856,.052)],[.009,.008,.006],hide,hand,8)
 T('Glove thumb',[(side*.296,.935,.055),(side*.278,.909,.076),(side*.29,.894,.083)],[.012,.01,.007],hide,hand,9)
 # Steel shells hug the shoulder and overlap down the arm.
 for layer in range(3):
  verts=[];faces=[];cy=1.465-layer*.034;cx=side*(.23+layer*.018)
  for row in range(7):
   u=row/6
   for column in range(13):
    v=column/12*2-1
    verts.append((cx+side*(u-.45)*.17,cy+.045*(1-(u*1.7-.3)**2)*math.sqrt(max(0,1-v*v)),v*(.135-layer*.012)))
  for row in range(6):
   for column in range(12):
    i=row*13+column;faces.append((i,i+1,i+14,i+13))
  shell=mesh('Contoured steel pauldron',verts,faces,silver,arm)
  solid=shell.modifiers.new('Steel thickness','SOLIDIFY');solid.thickness=.006
  bpy.context.view_layer.objects.active=shell;bpy.ops.object.modifier_apply(modifier=solid.name)
  T('Pauldron front gilt',[verts[row*13+12] for row in range(7)],[.004]*7,bronze,arm,7)
  T('Pauldron lower gilt',[verts[6*13+column] for column in range(13)],[.003]*13,bronze,arm,7)
 for j in [-1,1]:E('Shoulder rivet',(side*.24+j*.05,1.48,.078),(.004,.004,.004),bronze,arm)
# A licensed anatomical head foundation replaces the earlier procedural face.
# Only this head topology is derived from MakeHuman (CC0); see art/source/makehuman.
T('Neck',[(0,1.46,0),(0,1.61,.004)],[.064,.052],skinmat,'Head',24)
source_head=ROOT/'art/source/makehuman/head.obj'
head_vertices=[];head_faces=[]
for line in source_head.read_text().splitlines():
 if line.startswith('v '):
  x,y,z=map(float,line.split()[1:4]);head_vertices.append((x*.12,y*.12+.876,z*.12-.067))
 elif line.startswith('f '):head_faces.append(tuple(int(i)-1 for i in line.split()[1:]))
headskin=mat('Subtle face pigmentation',(.42,.24,.16),.78)
head=mesh('Anatomical adapted head',head_vertices,head_faces,headskin,'Head')
col=head.data.color_attributes.new(name='FaceTone',type='BYTE_COLOR',domain='CORNER')
for poly in head.data.polygons:
 for loop_index in poly.loop_indices:
  p=head_vertices[head.data.loops[loop_index].vertex_index];x,y,z=p
  color=(.42,.245,.17,1)
  if 1.644<y<1.653 and abs(x)<.027 and z>.10:color=(.35,.16,.12,1)
  elif 1.69<y<1.73 and z>.115:color=(.44,.23,.165,1)
  col.data[loop_index].color=color
vertex_color=headskin.node_tree.nodes.new('ShaderNodeVertexColor');vertex_color.layer_name='FaceTone'
headskin.node_tree.links.new(vertex_color.outputs['Color'],headskin.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
for side in [-1,1]:
 E('Eye sphere',(side*.037,1.75,.0824),(.0175,.0175,.0175),white,'Head')
 E('Iris',(side*.037,1.75,.0997),(.0065,.0065,.0015),iris,'Head')
 E('Pupil',(side*.037,1.75,.101),(.0025,.003,.001),pupil,'Head')
 E('Eye catchlight',(side*.034,1.753,.102),(.001,.001,.0008),white,'Head')
 T('Shaped brow',[(side*.018,1.78,.102),(side*.039,1.786,.105),(side*.065,1.776,.089)],[.003,.004,.001],hairmat,'Head',8)
# Swept layered hair locks with flattened cross sections and fine directional grooves.
E('Hair scalp',(0,1.824,-.022),(.115,.085,.094),hairmat,'Head')
for i in range(37):
 a=i*2.39996;x=math.cos(a)*.087;z=math.sin(a)*.063-.014
 tipx=x+.033;tipy=1.791-random.random()*.026;tipz=.07 if z>.0 else z-.035
 pts=[(x,1.827,z),(x-.018,1.906+random.random()*.026,z+.015),(tipx,1.87,z+.047),(tipx+.017,tipy,tipz)]
 smooth=[];radii=[]
 for step in range(13):
  t=step/12;weights=[(1-t)**3,3*(1-t)**2*t,3*(1-t)*t*t,t**3]
  smooth.append(tuple(sum(weights[k]*pts[k][axis] for k in range(4)) for axis in range(3)))
  radii.append(.024*(1-t)**.45+.0003)
 T('Curved swept hair lock',smooth,radii,hairmat,'Head',9)
# Scarf collar and long subdivided fabric, weighted across two scarf bones.
T('Rolled silk scarf collar',[(math.cos(i*math.tau/24)*.069,1.535+math.sin(i*math.tau/24)*.008,math.sin(i*math.tau/24)*.067) for i in range(25)],[.024]*25,scarfblue,'Chest',12)
mesh('Scarf front fold',[(-.075,1.54,.075),(.07,1.54,.075),(.04,1.46,.10),(-.06,1.49,.103)],[(0,1,2,3)],scarfblue,'Chest')
for tail in range(2):
 verts=[];faces=[]
 for row in range(23):
  t=row/22
  for j in range(7):
   u=j/6;verts.append((-.075-t*.86,1.53+math.sin(t*4)*.075-u*(.14-tail*.035)-t*.045,-.03+tail*.035+math.sin(u*math.pi*4+t*5)*.014))
 for row in range(22):
  for j in range(6):a=row*7+j;faces.append((a,a+1,a+8,a+7))
 scarf=mesh('Weighted silk scarf',verts,faces,scarfblue,'Scarf')
 group=scarf.vertex_groups.new(name='ScarfTip')
 for v in scarf.data.vertices:
  w=max(0,min(1,(-v.co.x-.30)/.34));group.add([v.index],w,'REPLACE');scarf.vertex_groups['Scarf'].add([v.index],1-w,'REPLACE')
scarfblue.use_backface_culling=False
# Chest gem, metallic setting and chain.
for side in [-1,1]:T('Chest chain',[(side*.09,1.49,.097),(side*.07,1.41,.135),(0,1.355,.142)],[.003]*3,bronze,'Chest',7)
mesh('Sapphire chest emblem',[(0,1.42,.132),(-.027,1.37,.141),(0,1.32,.14),(.027,1.37,.141),(0,1.37,.165)],[(0,1,4),(1,2,4),(2,3,4),(3,0,4)],bluegem,'Chest')
T('Chest jewel setting',[(0,1.425,.134),(-.032,1.37,.143),(0,1.314,.142),(.032,1.37,.143),(0,1.425,.134)],[.004]*5,bronze,'Chest',7)
# Ornate steel sword with a luminous inset, curved quillons and wrapped grip.
for y in [.88]:
 T('Sword grip',[(.28,y,.066),(.41,y,.066)],[.018,.018],hide,'Sword',14)
 for i in range(7):T('Grip winding',[(.29+i*.016,y-.016,.066),(.30+i*.016,y+.016,.066)],[.002,.002],bronze,'Sword',6)
 T('Curved crossguard',[(.47,y-.10,.07),(.435,y-.065,.07),(.42,y,.07),(.435,y+.065,.07),(.47,y+.10,.07)],[.003,.015,.019,.015,.003],bronze,'Sword',10)
 E('Sword pommel',(.255,y,.066),(.025,.023,.023),silver,'Sword')
 verts=[]
 for x,w in [(.44,.041),(.54,.045),(1.15,.027),(1.34,.001)]:
  for yy,zz in [(w,0),(0,.014),(-w,0),(0,-.014)]:verts.append((x,y+yy,.07+zz))
 faces=[]
 for j in range(3):
  for k in range(4):a=j*4+k;b=j*4+(k+1)%4;faces.append((a,b,b+4,a+4))
 mesh('Forged diamond sword blade',verts,faces,silver,'Sword')
 mesh('Sapphire blade inset',[(.47,y+.008,.086),(.47,y-.008,.086),(1.29,y,.086)],[(0,1,2)],bluegem,'Sword')
export('kael-guardian-skinned')
# The forest guardian: organically interwoven roots, hollow face, single spirit eye.
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
scene('Hollow Warden ancient roots')
bark2=surface('Ancient oak bark',(.15,.095,.042),'bark',.91)
moss2=surface('Living damp moss',(.11,.21,.029),'stone',.96)
rock2=surface('Mossy limestone',(.25,.28,.23),'stone',.9)
green=mat('Warden spirit green',(.025,.36,.075),.45,0,.5)
heart=mat('Warden hollow interior',(.012,.026,.015),.98)
# Individually routed trunk fibres leave negative space around a luminous heart.
for i in range(20):
 a=i*math.tau/20;r=.38+random.random()*.06
 pts=[]
 for j in range(7):
  y=-.65+j*.21;angle=a+math.sin(j*.55+i)*.14
  pts.append((math.cos(angle)*r*(.8+math.sin(j*.5)*.3),y,math.sin(angle)*r*.62))
 tube('Interwoven trunk root',pts,[.055,.08,.095,.085,.07,.055,.028],bark2,sides=12)
ell('Hollow heart',(0,.15,.12),(.19,.26,.13),heart)
for j in range(5):tube('Heart energy vein',[(-.12+j*.06,-.1,.25),(-.08+j*.035,.12,.27),(0,.35,.23)],[.007,.014,.003],green,sides=6)
# A face made of split bark plates and a pronounced brow.
for side in [-1,1]:
 tube('Face cheek',[(side*.16,.56,.10),(side*.19,.83,.14),(side*.11,1.03,.04)],[.09,.12,.075],bark2,sides=12)
 tube('Bark jaw',[(side*.16,.65,.16),(side*.09,.47,.20),(0,.40,.12)],[.08,.065,.018],bark2,sides=10)
 tube('Brow',[(side*.20,.92,.19),(side*.04,.89,.26)],[.06,.04],bark2,sides=10)
ell('Single ancient spirit eye',(0,.84,.215),(.055,.045,.018),green)
for side in [-1,1]:
 tube('Main branch crown',[(side*.11,1.0,0),(side*.31,1.18,-.03),(side*.43,1.50,-.07),(side*.53,1.74,-.02)],[.085,.07,.045,.002],bark2,sides=12)
 for j in range(3):
  x=side*(.25+j*.085);y=1.16+j*.16
  tube('Crown fork',[(x,y,-.03),(x+side*.19,y+.12,-.06),(x+side*.30,y+.28,-.05)],[.04,.025,.001],bark2,sides=9)
 # Root legs: tapered bundles rather than cylindrical humanoid legs.
 for k in range(5):
  x=side*(.23+(k-2)*.038)
  tube('Root leg',[(x,-.43,0),(x+side*.04,-.8,.03),(x+side*.07,-1.25,.08),(x+side*.13,-1.40,.25)],[.09,.075,.06,.012],bark2,sides=10)
 for j in range(3):tube('Anchoring foot root',[(side*.31,-1.18,.07),(side*(.32+j*.06),-1.38,.22),(side*(.4+j*.07),-1.4,.40)],[.05,.035,.002],bark2,sides=8)
 arm=empty('LeftArm' if side<0 else 'RightArm',(side*.43,.45,0))
 for k in range(6):
  a=k*math.tau/6
  tube('Braided arm',[(math.cos(a)*.10,0,math.sin(a)*.1),(side*.16+math.cos(a+.4)*.13,-.4,math.sin(a+.4)*.12),(side*.22+math.cos(a)*.1,-.8,.04+math.sin(a)*.1)],[.065,.075,.055],bark2,arm,sides=10)
 for k in range(4):tube('Root fingers',[(side*.22+(k-1.5)*.05,-.75,.05),(side*.26+(k-1.5)*.05,-.94,.11),(side*.20+(k-1.5)*.05,-1.02,.15)],[.035,.027,.008],bark2,arm,sides=8)
 # Layered shoulder bark and moss cushions.
 for j in range(5):
  ell('Shoulder bark',(side*.07,.02-j*.035,(j-2)*.06),(.19,.11,.08),bark2,arm)
  if j%2==0:ell('Shoulder moss',(side*.09,.095-j*.025,(j-2)*.06),(.13,.045,.07),moss2,arm)
 for j in range(4):tube('Shoulder twig',[(side*.05,.08,-.05),(side*(.18+j*.045),.19+j*.055,-.12),(side*(.25+j*.055),.3+j*.055,-.15)],[.028,.018,.001],bark2,arm,sides=8)
# Heavy stone mallet, irregular bevel and engraved glowing rune.
arm=bpy.data.objects.get('RightArm')
tube('Hammer haft',[(.22,-.84,.1),(.22,-1.3,.1),(.22,-1.65,.1)],[.045]*3,wood,arm,sides=12)
cube('Ancient hammer head',(.22,-1.55,.1),(.77,.33,.43),rock2,arm,bevel=.08)
for j in range(4):ell('Hammer moss',(.0+j*.12,-1.36,.14),(.08,.025,.09),moss2,arm)
tube('Hammer rune',[(.07,-1.52,.323),(.15,-1.44,.323),(.23,-1.52,.323),(.15,-1.61,.323),(.07,-1.52,.323)],[.009]*5,green,arm,sides=6)
# Small geometric leaves attached to shoulder and crown branches.
for i in range(95):
 side=-1 if i%2 else 1;x=side*random.uniform(.18,.62);y=random.uniform(.75,1.55);z=random.uniform(-.16,.03)
 o=ell('Crown leaf',(x,y,z),(.055,.018,.025),leafmats[i%3]);o.rotation_euler.y=random.uniform(-1,1)
export('hollow-warden-sculpted')
# Fully 3D environment kit: no background image, billboard plants or sprite platforms.
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
scene('Willowbrook 3D ravine')
# Y-up, stage local x=0..18; world instance is offset to x=40.
stone3=surface('Ravine layered stone',(.21,.245,.20),'stone',.95)
moss3=surface('Forest bank moss',(.12,.20,.035),'stone',.98)
soil3=surface('Forest soil',(.115,.075,.035),'stone',.98)
def rock(name,p,size,material,seed):
 rng=random.Random(seed)
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3,radius=1)
 o=finish(bpy.context.object,name,p,size,material)
 for v in o.data.vertices:
  f=1+rng.uniform(-.09,.09);v.co*=f
 for face in o.data.polygons:face.use_smooth=False
 return o
# Uneven geological masses below a continuous moss and soil surface.
for i in range(15):
 x=i*1.27
 rock('Fractured cliff',(x,-.74+random.uniform(-.2,.1),0),(1.0,.9,1.8),stone3,400+i)
 if i%2==0:rock('Lower cliff',(x,-1.7,-.15),(.9,.9,1.6),stone3,450+i)
verts=[];faces=[]
for i in range(73):
 x=i*.25
 for j in range(9):
  z=-1.6+j*.4;y=.015+math.sin(x*.9)*.012+random.uniform(-.012,.012)
  verts.append((x,y,z))
for i in range(72):
 for j in range(8):a=i*9+j;faces.append((a,a+1,a+10,a+9))
mesh('Continuous moss ground',verts,faces,moss3)
for i in range(55):
 x=random.uniform(0,18);z=random.choice([random.uniform(-1.65,-1.3),random.uniform(1.3,1.65)])
 rock('Bank moss rock',(x,-.01,z),(.2+random.random()*.25,.1+random.random()*.1,.25),moss3,500+i)
# Curving old oaks. Leaves are small solid meshes merged by material on export.
def oak(x,z,height,seed):
 rng=random.Random(seed)
 tube('Old oak trunk',[(x,0,z),(x-.1,height*.28,z+.1),(x+.15,height*.6,z),(x+.05,height*.85,z-.1)],[.32,.27,.19,.07],bark2,sides=14)
 branch_ends=[]
 for j in range(9):
  a=j*2.399;r=1.0+rng.random()*.5;y=height*(.53+rng.random()*.3)
  end=(x+math.cos(a)*r,y+.4,z+math.sin(a)*r)
  tube('Oak branch',[(x+.08,y-.7,z),(x+math.cos(a)*r*.55,y,z+math.sin(a)*r*.55),end],[.105,.06,.008],bark2,sides=10)
  branch_ends.append(end)
 verts=[];faces=[];material_ids=[]
 for i in range(4400):
  base=branch_ends[i%len(branch_ends)];p=(base[0]+rng.uniform(-.65,.65),base[1]+rng.uniform(-.22,.58),base[2]+rng.uniform(-.65,.65));a=rng.random()*math.tau
  length=rng.uniform(.10,.22);w=length*.4
  index=len(verts)
  tilt=rng.uniform(-1.25,1.25);rise=rng.uniform(-.7,.7)*length
  verts.extend([p,(p[0]+math.cos(a)*length,p[1]+rise,p[2]+math.sin(a)*length),(p[0]+math.cos(a)*length*.5-math.sin(a)*w*math.cos(tilt),p[1]+rise*.5+math.sin(tilt)*w,p[2]+math.sin(a)*length*.5+math.cos(a)*w*math.cos(tilt)),(p[0]+math.cos(a)*length*.5+math.sin(a)*w*math.cos(tilt),p[1]+rise*.5-math.sin(tilt)*w,p[2]+math.sin(a)*length*.5-math.cos(a)*w*math.cos(tilt))])
  faces.extend([(index,index+2,index+1),(index,index+1,index+3)]);material_ids.extend([i%3,i%3])
 me=bpy.data.meshes.new('Dense solid leaf canopy');me.from_pydata([V(q) for q in verts],[],faces);me.update()
 o=bpy.data.objects.new('Dense geometric oak canopy',me);bpy.context.scene.collection.objects.link(o)
 for m in leafmats:o.data.materials.append(m)
 for poly,index in zip(me.polygons,material_ids):poly.material_index=index
for i,(x,z,h) in enumerate([(0,-2,4.3),(4,-4,4.7),(10,-4.5,4.7),(17,-2.7,4.5),(1,1.7,5.5),(18,1.4,5.5)]):oak(x,z,h,100+i)
# Rear canyon walls and distant depth layers.
for side in [-1,1]:
 for i in range(6):
  x=9+side*(3.0+i*.8)
  rock('Rear canyon face',(x,1.7+i*.32,-14-i*.6),(1.4,2.8+i*.45,1.8),stone3,610+i+(10 if side>0 else 0))
  rock('Rear canyon moss',(x,4.2+i*.4,-13.5-i*.6),(1.2,.13,1.2),moss3,640+i)
water=mat('WaterfallStream',(.24,.48,.5),.28,.1)
for k in range(4):
 verts=[];faces=[]
 for j in range(30):
  t=j/29
  for side in [-1,1]:verts.append((8.8+k*.22+side*.22+math.sin(t*12+k)*.05,7.3-t*8,-13+math.sin(t*6)*.15+k*.015))
 for j in range(29):a=j*2;faces.append((a,a+1,a+3,a+2))
 mesh('Waterfall stream',verts,faces,water)
# Mossy ruin arch in depth, with individual beveled voussoirs.
for side in [-1,1]:
 for j in range(7):cube('Arch pillar',(4.5+side*.9,j*.39+.2,-4.5),(.45,.36,.6),stone3,bevel=.035)
for j in range(9):
 a=j*math.pi/8;o=cube('Arch stone',(4.5+math.cos(a)*.9,2.58+math.sin(a)*.9,-4.5),(.38,.43,.62),stone3,bevel=.035);o.rotation_euler.y=a-math.pi/2
# Ground plants have actual volumetric leaf geometry and stems.
for i in range(110):
 x=random.uniform(0,18);z=random.choice([random.uniform(.8,1.6),random.uniform(-1.7,-1.0)])
 for j in range(7):
  a=j*math.tau/7;length=random.uniform(.13,.31);p=(x,0,z);q=(x+math.cos(a)*length,.18+length*.3,z+math.sin(a)*length);mid=((p[0]+q[0])*.5,.17,(p[2]+q[2])*.5)
  verts=[];faces=[]
  for leaflet in range(1,8):
   t=leaflet/8;cx=x+math.cos(a)*length*t;cz=z+math.sin(a)*length*t;cy=.10+math.sin(t*math.pi*.85)*.12
   for side in [-1,1]:
    extent=(1-t)*.085+.012;index=len(verts)
    verts.extend([(cx,cy,cz),(cx-math.sin(a)*extent*side-math.cos(a)*.025,cy-.015,cz+math.cos(a)*extent*side-math.sin(a)*.025),(cx-math.sin(a)*extent*side,cy+.013,cz+math.cos(a)*extent*side),(cx+math.cos(a)*.014,cy+.006,cz+math.sin(a)*.014)])
    faces.extend([(index,index+1,index+2),(index,index+2,index+3)])
  mesh('Fern pinnate frond',verts,faces,leafmats[i%3])
 if i%9==0:
  tube('Flower stem',[(x,0,z),(x,.25,z)],[.008,.005],moss3,sides=6)
  for j in range(5):a=j*math.tau/5;ell('Gold woodland flower',(x+math.cos(a)*.026,.25,z+math.sin(a)*.026),(.024,.009,.015),gold)
# Distant rocky spires, viewed with parallax rather than a painted backdrop.
for i in range(13):
 x=-8+i*2.8;h=4+random.random()*6
 tube('Distant ridge',[(x,-2,-22),(x+.5,h*.55,-22),(x+.15,h,-22)],[2.4,1.5,.03],stone3,sides=9)
export('willowbrook-ravine')
import importlib.util
spec=importlib.util.spec_from_file_location('split_buffers',ROOT/'art/split_gltf_buffers.py')
splitter=importlib.util.module_from_spec(spec);spec.loader.exec_module(splitter)
splitter.split(OUT/'willowbrook-ravine.glb')
(OUT/'willowbrook-ravine.glb').unlink()
print('VERTICAL SLICE ART COMPLETE')
