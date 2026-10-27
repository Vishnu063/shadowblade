"""Original modeled forest assets. Blender 4.3+, no external asset inputs.
Coordinates in author helpers use Godot's Y-up, converted for glTF export.
Run: blender -b --python art/forest_blender.py
"""
import bpy, math, random
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]; OUT=ROOT/'assets/forest'; OUT.mkdir(exist_ok=True)
random.seed(731)
def V(p):return Vector((p[0],-p[2],p[1]))
def mat(name,color,rough=.75,metal=0,emission=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(*color,1);bs.inputs['Roughness'].default_value=rough;bs.inputs['Metallic'].default_value=metal
 if emission:bs.inputs['Emission Color'].default_value=(*color,1);bs.inputs['Emission Strength'].default_value=emission
 return m
skin=mat('Warm skin',(.57,.32,.19),.8);hair=mat('Chestnut hair',(.032,.024,.023));ivory=mat('Woven linen',(.65,.59,.46));blue=mat('Indigo wool',(.025,.12,.27));scarfmat=mat('Cobalt scarf',(.025,.20,.58),.62);leather=mat('Oiled leather',(.16,.075,.029),.52);pants=mat('Charcoal trousers',(.039,.055,.067));steel=mat('Blue steel',(.35,.57,.68),.28,.65);gold=mat('Brass',(.48,.30,.09),.4,.65);eye=mat('Eye dark',(.013,.018,.021));white=mat('Eye ivory',(.8,.79,.70));blade=mat('Arcane blade',(.06,.47,.9),.25,.25,1.8)
stone=mat('Weathered limestone',(.24,.27,.25));bark=mat('Oak bark',(.18,.12,.064));moss=mat('Damp moss',(.11,.22,.038));leafmats=[mat('Leaf '+str(i),c) for i,c in enumerate([(.025,.10,.014),(.055,.17,.025),(.12,.24,.037)])];wood=mat('Aged timber',(.22,.14,.065));plaster=mat('Lime plaster',(.57,.48,.31));slate=mat('Blue slate',(.08,.13,.17));glass=mat('Warm window',(.7,.39,.09),.5,0,.5)
# Original tileable albedo variation; no photographs or borrowed texture data.
for material,kind in [(stone,'stone'),(bark,'bark'),(wood,'bark'),(leather,'leather'),(ivory,'cloth'),(blue,'cloth'),(moss,'moss')]:
 size=128;im=bpy.data.images.new(material.name+' grain',width=size,height=size);pixels=[];base=material.diffuse_color[:3]
 for y in range(size):
  for x in range(size):
   n=random.random()-.5; wave=math.sin(x*.4+math.sin(y*.09)*2) if kind=='bark' else math.sin(x*2)*math.sin(y*2)
   f=.9+n*.13+wave*(.15 if kind=='bark' else .045)
   pixels.extend([min(1,c*f) for c in base]+[1])
 im.pixels=pixels;im.pack();tex=material.node_tree.nodes.new('ShaderNodeTexImage');tex.image=im;material.node_tree.links.new(tex.outputs['Color'],material.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
def scene(name):
 s=bpy.data.scenes.new(name);bpy.context.window.scene=s;return s
def empty(name,p=(0,0,0),parent=None):
 o=bpy.data.objects.new(name,None);bpy.context.scene.collection.objects.link(o);o.parent=parent;o.location=V(p);return o
def finish(o,name,p,scale,material,parent=None):
 o.name=name;o.parent=parent;o.location=V(p);o.scale=(scale[0],scale[2],scale[1]);o.data.materials.append(material)
 for poly in o.data.polygons:poly.use_smooth=True
 return o
def ell(name,p,scale,material,parent=None):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=10);return finish(bpy.context.object,name,p,scale,material,parent)
def cube(name,p,size,material,parent=None,bevel=.025):
 bpy.ops.mesh.primitive_cube_add(size=1);o=finish(bpy.context.object,name,p,size,material,parent)
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  mod=o.modifiers.new('Soft worn edges','BEVEL');mod.width=bevel;mod.segments=3
  bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)
 mod=o.modifiers.new('Weighted corner normals','WEIGHTED_NORMAL')
 bpy.ops.object.modifier_apply(modifier=mod.name)
 return o
def tube(name,points,radii,material,parent=None,sides=10):
 verts=[];faces=[]
 for j,p in enumerate(points):
  direction=V(points[min(j+1,len(points)-1)])-V(points[max(0,j-1)])
  direction.normalize();u=direction.cross(Vector((0,1,0)))
  if u.length<.01:u=direction.cross(Vector((1,0,0)))
  u.normalize();v=direction.cross(u)
  for i in range(sides):verts.append(V(p)+(u*math.cos(i*math.tau/sides)+v*math.sin(i*math.tau/sides))*radii[j])
 for j in range(len(points)-1):
  for i in range(sides):a=j*sides+i;b=j*sides+(i+1)%sides;faces.append((a,b,b+sides,a+sides))
 faces += [tuple(reversed(range(sides))),tuple((len(points)-1)*sides+i for i in range(sides))]
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.scene.collection.objects.link(o);o.parent=parent;o.data.materials.append(material)
 for f in me.polygons:f.use_smooth=True
 return o
def export(name):
 bpy.ops.object.select_all(action='DESELECT')
 # Merge only rigid siblings. Keep the pivot hierarchy for gameplay animation.
 parents={o.parent for o in bpy.context.scene.objects if o.type=='MESH'}
 for parent in parents:
  objs=[o for o in bpy.context.scene.objects if o.type=='MESH' and o.parent==parent]
  if len(objs)>1:
   bpy.ops.object.select_all(action='DESELECT')
   for o in objs:o.select_set(True)
   bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join()
 for obj in bpy.context.scene.objects:
  if obj.type!='MESH':continue
  uv=obj.data.uv_layers.active or obj.data.uv_layers.new(name='SurfaceUV')
  for face in obj.data.polygons:
   axis=max(range(3),key=lambda i:abs(face.normal[i]));axes=[i for i in range(3) if i!=axis]
   for li in face.loop_indices:
    co=obj.data.vertices[obj.data.loops[li].vertex_index].co
    uv.data[li].uv=(co[axes[0]]*2,co[axes[1]]*2)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_active_scene=True,export_yup=True,export_animations=False)
 print('EXPORTED',name)
scene('Kael')
# A tapered torso and layered waistcoat instead of cylinders/boxes.
ell('Linen torso',(0,.23,0),(.225,.265,.125),ivory)
ell('Waistcoat',(0,.20,.027),(.218,.25,.13),blue)
for side in [-1,1]:
 tube('Vest edge',[(side*.095,.4,.108),(side*.11,.21,.118),(side*.15,-.01,.09)],[.012]*3,leather)
 for y in [.18,.26,.34]:ell('Brass button',(side*.055,y,.129),(.008,.008,.006),gold)
cube('Belt',(0,-.025,.005),(.43,.06,.265),leather,bevel=.015);cube('Buckle',(0,-.025,.148),(.065,.05,.014),gold,bevel=.006)
strap=cube('Cross strap',(-.05,.24,.14),(.035,.35,.022),leather,bevel=.009);strap.rotation_euler.y=.35
ell('Pouch',(-.22,-.045,.045),(.065,.075,.055),leather)
tube('Neck',[(0,.44,0),(0,.55,0)],[.068,.06],skin)
ell('Face',(0,.65,.018),(.103,.138,.096),skin)
ell('Jaw',(.006,.598,.045),(.077,.065,.069),skin)
for side in [-1,1]:
 ell('Ear',(side*.101,.65,.01),(.022,.037,.015),skin)
 ell('Eye',(side*.041,.67,.102),(.027,.012,.008),white)
 ell('Iris',(side*.035,.67,.109),(.010,.010,.004),eye)
 tube('Brow',[(side*.065,.691,.102),(side*.027,.695,.111)],[.007,.008],hair,sides=6)
ell('Nose',(.006,.642,.119),(.018,.029,.021),skin)
tube('Mouth',[(-.025,.605,.106),(.02,.603,.107)],[.003,.003],leather,sides=5)
ell('Hair cap',(0,.726,-.005),(.112,.087,.105),hair)
for i in range(11):
 x=-.10+i*.019
 tube('Swept hair',[(x,.752,-.038),(x+.026,.798,.015),(x+.045,.765,.082),(x+.028,.706-random.random()*.035,.101)],[.023,.026,.02,.001],hair,sides=7)
for side in [-1,1]:
 leg=empty('LeftLeg' if side==-1 else 'RightLeg',(side*.105,-.055,0))
 tube('Thigh',[(0,0,0),(side*.01,-.18,.005),(side*.015,-.34,.025)],[.092,.078,.058],pants,leg)
 knee=empty('Knee',(side*.015,-.34,.025),leg)
 tube('Shin',[(0,0,0),(-side*.012,-.17,-.02),(0,-.31,0)],[.058,.055,.045],pants,knee)
 ell('Leather boot',(.028,-.34,.045),(.074,.105,.115),leather,knee)
 cube('Sole',(.035,-.415,.05),(.15,.026,.22),leather,knee,bevel=.012)
 tube('Boot cuff',[(0,-.18,0),(0,-.25,0)],[.064,.066],leather,knee)
 for y in [-.27,-.30,-.33]:tube('Lace',[(-.04,y,.105),(.04,y-.014,.11)],[.003]*2,ivory,knee,sides=5)
 arm=empty('LeftArm' if side==-1 else 'SwordArm',(side*.23,.40,0))
 tube('Sleeve',[(0,0,0),(side*.045,-.105,.01),(side*.04,-.23,.025)],[.075,.07,.052],ivory,arm)
 elbow=empty('Elbow',(side*.04,-.23,.025),arm)
 tube('Forearm',[(0,0,0),(side*.055,-.15,.055)],[.049,.035],skin,elbow)
 tube('Bracer',[(side*.018,-.04,.015),(side*.05,-.13,.048)],[.055,.045],leather,elbow)
 ell('Hand',(side*.06,-.19,.065),(.04,.058,.033),skin,elbow)
scarf=empty('Scarf',(0,.47,0))
tube('Scarf collar',[(-.055,0,0),(0,.025,0),(.055,0,0)],[.082,.083,.082],scarfmat,scarf)
tube('Scarf knot',[(-.055,0,.055),(-.12,-.03,.045)],[.045,.025],scarfmat,scarf)
# Double-sided cloth strip with a shaped silhouette and center fold.
verts=[];faces=[]
for i in range(10):
 x=-.10-i*.067;y=.02+math.sin(i*.65)*.05
 for j in range(3):verts.append(V((x,y-j*.05,.01+(.025 if j==1 else 0))))
for i in range(9):
 for j in range(2):a=i*3+j;faces.append((a,a+3,a+4,a+1))
me=bpy.data.meshes.new('Scarf cloth');me.from_pydata(verts,[],faces);o=bpy.data.objects.new('Tail',me);bpy.context.scene.collection.objects.link(o);o.parent=scarf;o.data.materials.append(scarfmat);scarfmat.use_backface_culling=False
sword=empty('Sword',(.34,.0,.1));cube('Grip',(.035,0,0),(.15,.028,.035),leather,sword,.006);cube('Guard',(.12,0,0),(.035,.18,.045),gold,sword,.008)
tube('Blade',[(.14,0,0),(.58,0,0),(.87,0,0)],[.031,.025,.001],blade,sword,sides=4)
export('kael')
scene('Rounded stones')
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=.5);o=bpy.context.object;o.name='Stone'
for vert in o.data.vertices:
 p=vert.co;f=1+random.uniform(-.10,.10);p*=f;p.z*=.72
for p in o.data.polygons:p.use_smooth=False
o.data.materials.append(stone);bev=o.modifiers.new('Worn stone','BEVEL');bev.width=.018;bev.segments=2;bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=bev.name)
export('stone')
scene('Oak')
tube('Ancient trunk',[(0,0,0),(.08,1.1,.03),(-.12,2.7,.03),(.16,4.1,-.15),(.05,5.3,0)],[.38,.30,.21,.13,.03],bark,sides=14)
clusters=[]
for i in range(13):
 a=i*2.4;end=(math.cos(a)*(1.7+random.random()*.6),4.5+random.random()*1.5,math.sin(a)*(1.2+random.random()*.8))
 tube('Branch',[(.0,2.4+i*.14,0),(end[0]*.45,3.7+random.random()*.3,end[2]*.4),end],[.13,.08,.012],bark)
 clusters.append(end)
verts=[];faces=[];matids=[]
for i in range(1000):
 c=random.choice(clusters);a=random.random()*math.tau;r=random.random()**.5
 p=Vector((c[0]+math.cos(a)*r*.95,c[1]+random.uniform(-.45,.55),c[2]+math.sin(a)*r*.9))
 width=random.uniform(.055,.11);length=width*2.4;direction=Vector((math.cos(a),random.uniform(-.3,.3),math.sin(a)));cross=Vector((-math.sin(a),0,math.cos(a)))
 base=len(verts)
 for v in [p-direction*length*.5,p-cross*width,p+Vector((0,.035,0)),p+cross*width,p+direction*length*.5]:verts.append(V(v))
 faces +=[(base,base+1,base+2),(base,base+2,base+3),(base+2,base+1,base+4),(base+3,base+2,base+4)];matids.extend([i%3]*4)
me=bpy.data.meshes.new('Individual curved leaves');me.from_pydata(verts,[],faces);o=bpy.data.objects.new('Canopy',me);bpy.context.scene.collection.objects.link(o)
for m in leafmats:m.use_backface_culling=False;o.data.materials.append(m)
for poly,mi in zip(me.polygons,matids):poly.material_index=mi
export('oak')
scene('Ruins')
for side in [-1,1]:
 for row in range(7):cube('Pillar',(side*1.5,.23+row*.44,0),(.63+random.uniform(-.07,.07),.42,.78),stone,bevel=.055)
for i in range(13):
 a=i/12*math.pi;o=cube('Voussoir',(math.cos(a)*1.5,2.85+math.sin(a)*1.5,0),(.39,.55,.82),stone,bevel=.04);o.rotation_euler.y=-(a-math.pi/2)
for i in range(26):
 a=random.random()*math.tau;y=random.uniform(.2,3.5);ell('Moss',(random.choice([-1,1])*1.5+random.uniform(-.2,.2),y,.41),(.13,.055,.02),moss)
export('ruin')
scene('Timber lodge')
cube('Plaster',(0,1.05,0),(2.6,2.1,1.9),plaster,bevel=.05)
for x in [-1.23,0,1.23]:cube('Upright',(x,1.0,1.0),(.12,2.1,.12),wood)
for y in [.18,1.9]:cube('Beam',(0,y,1.01),(2.7,.14,.13),wood)
for side in [-1,1]:
 o=cube('Brace',(side*.65,1.0,1.02),(.09,1.85,.10),wood);o.rotation_euler.y=side*.55
 for row in range(6):
  for col in range(9):
   o=cube('Shingle',(side*(.13+row*.25),2.91-row*.19,-.99+col*.25),(.37,.055,.27),slate,bevel=.015);o.rotation_euler.y=side*.65
cube('Door',(-.4,.67,1.04),(.66,1.34,.09),wood)
for x in [.65]:
 cube('Window frame',(x,1.16,1.05),(.6,.72,.1),wood)
 cube('Amber pane',(x,1.16,1.11),(.48,.59,.03),glass)
 for sz in [(.5,.035,.04),(.035,.6,.04)]:cube('Mullion',(x,1.16,1.14),sz,wood,.0 if False else None)
export('cottage')
scene('Veil hunter')
fur=mat('Midnight velvet',(.045,.022,.075),.8);membrane=mat('Purple wing membrane',(.13,.045,.19),.6);membrane.use_backface_culling=False;violet=mat('Void eyes',(.7,.025,.9),.35,0,2)
ell('Body',(0,-.02,0),(.16,.24,.13),fur);ell('Face',(0,.18,.04),(.19,.14,.12),fur)
for side in [-1,1]:
 tube('Ear',[(side*.12,.24,0),(side*.19,.45,-.02)],[.06,.001],fur)
 ell('Eye',(side*.075,.2,.15),(.037,.028,.017),violet)
 wing=empty('LeftWing' if side==-1 else 'RightWing',(side*.10,.1,-.02))
 boundary=[(0,0,0),(.22,.30,0),(.47,.43,.01),(.76,.20,0),(.65,-.07,0),(.45,.03,0),(.38,-.25,.01),(.18,-.10,0),(.07,-.37,0)]
 verts=[V((side*x,y,z)) for x,y,z in boundary];faces=[(0,i,i+1) for i in range(1,len(verts)-1)]
 me=bpy.data.meshes.new('Curved membrane');me.from_pydata(verts,[],faces);obj=bpy.data.objects.new('Wing',me);bpy.context.scene.collection.objects.link(obj);obj.parent=wing;obj.data.materials.append(membrane)
 for tip in [3,6,8]:
  end=boundary[tip];tube('Finger',[(0,0,0),(side*end[0]*.55,end[1]*.7,.012),(side*end[0],end[1],end[2])],[.018,.012,.003],fur,wing)
for i in range(3):tube('Trailing tendril',[(i*.06-.06,-.2,0),(i*.07-.07,-.45,-.02),(i*.15-.15,-.6,.015)],[.025,.013,.001],fur)
export('veil_moth')
scene('Fern')
for frond in range(9):
 a=frond*math.tau/9
 pts=[]
 for i in range(7):
  t=i/6;pts.append((math.cos(a)*t*.45,math.sin(t*math.pi*.7)*.3,math.sin(a)*t*.45))
 tube('Stem',pts,[.009*(1-i/7) for i in range(7)],moss,sides=5)
 for i in range(1,6):
  p=Vector(pts[i]);cross=Vector((-math.sin(a),0,math.cos(a)))
  for side in [-1,1]:
   tip=p+cross*side*(.13*(1-i/7))+Vector((math.cos(a)*.05,.025,math.sin(a)*.05))
   tube('Leaf',[p,(p+tip)/2+Vector((0,.015,0)),tip],[.015,.032*(1-i/8),.001],leafmats[i%3],sides=4)
export('fern')
# Save editable native source containing each asset as its own Blender scene.
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/forest.blend'))
