"""Original Kael visual revision. Preserve the gameplay rig/pivot names.
Run with Blender 4.2+: blender -b --python art/build_kael_v2.py.
Reuses only original project material/mesh helpers; exports kael-v2.glb.
"""
from pathlib import Path
import math, random
_source = Path(__file__).with_name('forest_blender.py')
exec(compile(_source.read_text().split("scene('Kael')")[0], str(_source), 'exec'))
scene('Kael visual revision')
# Slim tapered cloth construction, rather than the earlier rounded belly.
def garment(name, rings, material):
 verts=[];faces=[];n=20
 for y,w,d in rings:
  for i in range(n):
   a=i*math.tau/n;verts.append(V((math.cos(a)*w,y,math.sin(a)*d)))
 for row in range(len(rings)-1):
  for i in range(n):
   a=row*n+i;b=row*n+(i+1)%n;faces.append((a,b,b+n,a+n))
 faces.append(tuple(reversed(range(n))));faces.append(tuple((len(rings)-1)*n+i for i in range(n)))
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.scene.collection.objects.link(o);o.data.materials.append(material)
 for p in me.polygons:p.use_smooth=True
 return o
# Ivory undershirt, blue long tunic, tailored waist, broad soft shoulders.
garment('Linen shirt',[(.02,.145,.095),(.2,.175,.102),(.40,.215,.10),(.45,.09,.075)],ivory)
garment('Blue tunic',[(-.19,.22,.13),(-.06,.18,.105),(.10,.145,.10),(.28,.18,.105),(.405,.205,.10)],blue)
# Split front, hem and stitched lapels.
for side in [-1,1]:
 tube('Tunic seam',[(side*.20,-.18,.095),(side*.14,-.04,.096),(side*.09,.12,.108),(side*.075,.34,.103)],[.009]*4,leather,sides=7)
 tube('Gold hem',[(side*.02,-.18,.132),(side*.12,-.18,.12),(side*.20,-.18,.09)],[.005]*3,gold,sides=6)
 for y in [.13,.22,.31]:ell('Tunic fastener',(side*.032,y,.111),(.005,.007,.004),gold)
cube('Waist belt',(0,-.035,.008),(.355,.065,.242),leather,bevel=.015)
cube('Brass buckle',(0,-.035,.139),(.055,.047,.018),gold,bevel=.008)
strap=cube('Shoulder strap',(-.055,.215,.12),(.034,.355,.018),leather,bevel=.007);strap.rotation_euler.y=.36
ell('Hip pouch',(-.19,-.08,.055),(.055,.075,.044),leather)
for side in [-1,1]:
 ell('Leather shoulder',(side*.205,.38,.005),(.065,.032,.105),leather)
 tube('Shoulder piping',[(side*.15,.406,.08),(side*.23,.398,.065)],[.006,.006],gold,sides=6)
# A smaller natural face, cheek/jaw definition and restrained eyes.
tube('Neck',[(0,.43,0),(0,.55,0)],[.058,.052],skin)
ell('Head',(0,.655,.013),(.095,.13,.089),skin)
ell('Jaw',(0,.594,.035),(.067,.061,.061),skin)
for side in [-1,1]:
 ell('Cheek',(side*.052,.639,.073),(.033,.032,.026),skin)
 ell('Ear',(side*.095,.652,.008),(.017,.031,.013),skin)
 ell('Eye white',(side*.038,.674,.094),(.018,.008,.005),white)
 ell('Iris',(side*.037,.673,.099),(.006,.006,.003),eye)
 tube('Upper eyelid',[(side*.054,.678,.096),(side*.022,.679,.099)],[.0035,.0035],hair,sides=6)
 tube('Brow',[(side*.058,.695,.091),(side*.024,.699,.101)],[.006,.005],hair,sides=6)
ell('Nose',(.002,.644,.106),(.012,.024,.016),skin)
tube('Mouth',[(-.019,.607,.091),(.017,.605,.092)],[.0025,.002],leather,sides=6)
ell('Hair base',(0,.729,-.009),(.102,.077,.092),hair)
# Irregular swept locks with tapered tips and a clear silhouette.
for i in range(14):
 x=-.095+(i%7)*.029;rear=-.055 if i<7 else .018
 tube('Swept hair',[(x,.742,rear),(x-.018,.794+random.random()*.025,rear+.027),(x+.035,.791,rear+.07),(x+.048,.72-random.random()*.023,.101)],[.023,.027,.022,.001],hair,sides=8)
for side in [-1,1]:
 tube('Sideburn',[(side*.09,.72,.035),(side*.094,.655,.047)],[.015,.003],hair,sides=6)
# Preserve LeftLeg / RightLeg / Knee animation pivots and floor height.
for side in [-1,1]:
 leg=empty('LeftLeg' if side==-1 else 'RightLeg',(side*.11,-.06,0))
 tube('Trouser thigh',[(0,0,0),(side*.012,-.17,.005),(side*.014,-.34,.02)],[.077,.069,.05],pants,leg)
 knee=empty('Knee',(side*.014,-.34,.02),leg)
 tube('Calf',[(0,0,0),(-side*.01,-.17,-.012),(0,-.30,.008)],[.05,.047,.039],pants,knee)
 tube('Boot shaft',[(0,-.14,.007),(0,-.29,.025)],[.057,.05],leather,knee)
 ell('Boot foot',(.012,-.345,.046),(.061,.076,.087),leather,knee)
 cube('Boot sole',(.013,-.414,.045),(.13,.024,.18),leather,knee,bevel=.009)
 tube('Boot cuff',[(-.042,-.16,.044),(.04,-.16,.044)],[.009,.009],gold,knee,sides=6)
 for y in [-.24,-.275,-.31]:tube('Boot lace',[(-.035,y,.081),(.035,y-.01,.084)],[.0025,.0025],ivory,knee,sides=5)
 arm=empty('LeftArm' if side==-1 else 'SwordArm',(side*.22,.385,0))
 tube('Soft linen sleeve',[(0,0,0),(side*.035,-.11,.008),(side*.04,-.22,.025)],[.067,.065,.044],ivory,arm,sides=14)
 elbow=empty('Elbow',(side*.04,-.22,.025),arm)
 tube('Forearm',[(0,0,0),(side*.05,-.14,.05)],[.04,.03],skin,elbow)
 tube('Leather bracer',[(side*.01,-.035,.012),(side*.043,-.125,.043)],[.047,.038],leather,elbow,sides=12)
 tube('Bracer edge',[(side*.01,-.035,.012),(side*.015,-.052,.018)],[.048,.048],gold,elbow,sides=10)
 ell('Glove',(side*.06,-.185,.064),(.035,.05,.029),leather,elbow)
 ell('Fingers',(side*.06,-.213,.068),(.027,.024,.023),skin,elbow)
# A fuller cobalt scarf, with cloth folds and two flowing tails.
scarf=empty('Scarf',(0,.475,0))
tube('Scarf collar',[(-.055,0,0),(0,.028,.004),(.055,0,0)],[.076,.078,.076],scarfmat,scarf,sides=14)
tube('Scarf knot',[(-.055,0,.058),(-.11,-.025,.045)],[.04,.025],scarfmat,scarf)
for tail in range(2):
 verts=[];faces=[]
 for i in range(12):
  x=-.09-i*.06;y=.005+math.sin(i*.55+tail*.4)*.055-tail*.045
  for j in range(3):verts.append(V((x,y-j*(.043 if tail==0 else .027),-.01+tail*.025+(.023 if j==1 else 0))))
 for i in range(11):
  for j in range(2):a=i*3+j;faces.append((a,a+3,a+4,a+1))
 me=bpy.data.meshes.new('Scarf fold');me.from_pydata(verts,[],faces);o=bpy.data.objects.new('Scarf tail',me);bpy.context.scene.collection.objects.link(o);o.parent=scarf;o.data.materials.append(scarfmat)
scarfmat.use_backface_culling=False
# Broad diamond-section blade, crossguard and leather grip.
sword=empty('Sword',(.34,0,.1))
cube('Sword grip',(.035,0,0),(.15,.032,.038),leather,sword,bevel=.006)
cube('Crossguard',(.12,0,0),(.04,.19,.05),gold,sword,bevel=.011)
ell('Pommel',(-.05,0,0),(.032,.03,.03),gold,sword)
verts=[]
for x,width in [(.15,.045),(.57,.035),(.91,.001)]:
 for y,z in [(width,0),(0,.012),(-width,0),(0,-.012)]:verts.append(V((x,y,z)))
faces=[]
for row in range(2):
 for i in range(4):a=row*4+i;b=row*4+(i+1)%4;faces.append((a,b,b+4,a+4))
me=bpy.data.meshes.new('Arcane blade');me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new('Arcane blade',me);bpy.context.scene.collection.objects.link(o);o.parent=sword;o.data.materials.append(blade)
export('kael-v2')
