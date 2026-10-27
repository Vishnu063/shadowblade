"""Original mobile-scale boss meshes; concept board is a higher-detail target.
blender -b --python art/build_villains.py
"""
from pathlib import Path
import math
_source=Path(__file__).with_name('forest_blender.py')
exec(compile(_source.read_text().split("scene('Kael')")[0],str(_source),'exec'))
obsidian=mat('Basalt',(.045,.035,.045),.55,.3)
fire=mat('Molten cracks',(1,.21,.012),.35,.1,2)
frost=mat('Ice silver',(.48,.73,.82),.25,.5)
ice=mat('Ice glow',(.12,.68,.95),.25,.1,1.1)
robe=mat('Glacier cloth',(.64,.77,.81),.8)
bronze=mat('Feather bronze',(.46,.28,.1),.42,.6)
wind=mat('Wind jade',(.19,.7,.55),.35,.25,.5)
storm=mat('Storm stone',(.11,.12,.19),.45,.4)
lightning=mat('Storm core',(.54,.19,.95),.25,.2,1.8)
void=mat('Void velvet',(.045,.025,.10),.75)
shadow=mat('Void flame',(.4,.09,.7),.4,0,1.2)
forestglow=mat('Forest spirit',(.19,.75,.22),.5,0,1.3)
names=['hollow-warden-v2','cinder-sentinel','frostbound-keeper','gale-harrier','tempest-colossus','void-herald']
for region,name in enumerate(names):
 for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
 scene(name)
 # Distinct anatomy and proportions; common named arm pivots retain attack poses.
 main=[bark,obsidian,robe,bronze,storm,void][region]
 glow=[forestglow,fire,ice,wind,lightning,shadow][region]
 width=[.49,.55,.27,.29,.63,.27][region]
 if region in [2,5]:
  tube('Flowing robe',[(0,-1.32,0),(0,-.75,0),(0,-.18,0),(0,.55,0)],[.51,.36,.23,.29],main,sides=16)
  for i in range(8):
   a=i*math.tau/8
   tube('Fold piping',[(math.cos(a)*.28,.25,math.sin(a)*.28),(math.cos(a)*.35,-.65,math.sin(a)*.35),(math.cos(a)*.5,-1.32,math.sin(a)*.5)],[.013,.02,.006],gold if region==5 else frost,sides=6)
 else:
  for side in [-1,1]:
   tube('Armored leg',[(side*width*.5,-.25,0),(side*width*.6,-.8,.015),(side*width*.7,-1.27,.08)],[width*.34,width*.3,width*.28],main,sides=12)
   ell('Foot',(side*width*.7,-1.28,.13),(width*.37,.13,.27),main)
 tube('Tapered torso',[(0,-.4,0),(0,.1,0),(0,.6,0)],[width*.64,width,width*.8],main,sides=14)
 if region==0:
  for i in range(12):
   a=i*math.tau/12
   tube('Root ribs',[(math.cos(a)*.22,-.6,math.sin(a)*.22),(math.cos(a)*.5,.05,math.sin(a)*.32),(math.cos(a)*.32,.6,math.sin(a)*.25)],[.065,.07,.025],bark,sides=8)
   if i%2==0:ell('Moss clump',(math.cos(a)*.44,.3,math.sin(a)*.34),(.17,.12,.12),moss)
 elif region in [1,4]:
  for y in [-.2,.1,.4]:
   cube('Breastplate',(0,y,.23),(width*1.6,.24,.17),obsidian if region==1 else bronze,bevel=.055)
   tube('Energy seam',[(-width*.7,y,.33),(0,y+.06,.36),(width*.7,y,.33)],[.015,.025,.015],glow,sides=6)
 else:
  ell('Breastplate',(0,.32,.1),(width*.85,.34,.19),frost if region==2 else main)
 ell('Core',(0,.25,.34),(.1,.13,.055),glow)
 ell('Head',(0,.82,.015),(.20,.27,.18),main)
 if region in [2,5]:
  tube('Hood',[(0,.68,0),(0,.96,-.02),(0,1.2,-.05)],[.24,.22,.025],robe if region==2 else void,sides=12)
  ell('Mask',(0,.82,.18),(.13,.18,.035),obsidian)
 elif region in [1,4]:
  cube('Helmet',(0,.88,.035),(.42,.46,.34),main,bevel=.055)
  tube('Helmet ridge',[(0,1.05,-.13),(0,1.18,.02),(0,1.05,.18)],[.035,.08,.035],bronze,sides=6)
 elif region==3:
  tube('Beaked mask',[(0,.9,-.12),(0,.86,.16),(0,.76,.38)],[.18,.16,.01],bronze,sides=8)
 for side in [-1,1]:
  ell('Eye',(side*.08,.88,.20),(.035,.016,.018),glow)
  arm=empty('LeftArm' if side<0 else 'RightArm',(side*width,.48,0))
  tube('Upper arm',[(0,0,0),(side*.16,-.24,0),(side*.2,-.47,.02)],[width*.32,width*.29,width*.24],main,arm,sides=12)
  tube('Forearm',[(side*.2,-.44,.02),(side*.24,-.81,.10)],[width*.29,width*.37],main,arm,sides=12)
  ell('Fist',(side*.25,-.87,.10),(width*.3,width*.35,width*.3),main,arm)
  if region in [1,4]:
   for j in range(3):
    cube('Layered shoulder',(side*.05,.02-j*.06,0),(.46,.17,.52-j*.07),bronze if region==4 else obsidian,arm,bevel=.04)
   tube('Gauntlet seam',[(side*.2,-.5,.2),(side*.24,-.8,.25)],[.025,.035],glow,arm,sides=7)
  if region==0:
   tube('Antler',[(side*.13,1.02,0),(side*.36,1.24,0),(side*.47,1.51,-.02),(side*.56,1.65,.05)],[.07,.055,.035,.001],bark,sides=8)
   tube('Antler fork',[(side*.33,1.22,0),(side*.62,1.37,0),(side*.75,1.49,-.04)],[.04,.03,.001],bark,sides=7)
  if region==2:
   for j in range(3):
    tube('Crystal crown',[(side*(.07+j*.06),1.03,0),(side*(.09+j*.075),1.43-j*.09,0)],[.055,.001],ice,sides=5)
  if region==3:
   for j in range(5):
    tube('Wing feather',[(side*.2,.54,-.12),(side*(.48+j*.1),.6+j*.04,-.17),(side*(.85+j*.09),.9+j*.1,-.2)],[.08,.07,.002],bronze,sides=7)
   tube('Curved blade',[(side*.24,-.82,.12),(side*.5,-.8,.12),(side*.75,-.57,.12),(side*.8,-.4,.12)],[.04,.07,.05,.001],steel,arm,sides=7)
 if region==0:
  arm=bpy.data.objects.get('RightArm')
  tube('Hammer haft',[(.23,-.78,.1),(.23,-1.12,.1),(.23,-1.5,.1)],[.04]*3,wood,arm)
  cube('Stone hammer',(.23,-1.42,.1),(.72,.32,.37),stone,arm,bevel=.07)
 if region in [2,5]:
  arm=bpy.data.objects.get('LeftArm')
  tube('Staff',[(-.22,-1.6,.1),(-.22,-.5,.1),(-.22,.45,.1)],[.025]*3,gold if region==5 else frost,arm)
  ell('Staff orb',(-.22,.52,.1),(.13,.13,.13),glow,arm)
 if region==4:
  for side in [-1,1]:
   tube('Conductor',[(side*.3,.55,-.1),(side*.65,.95,-.1),(side*.73,1.2,-.1)],[.07,.04,.015],bronze,sides=8)
 export(name)
