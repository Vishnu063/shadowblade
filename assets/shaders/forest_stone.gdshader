shader_type spatial;
render_mode cull_back;
uniform vec3 rock_dark = vec3(.12,.16,.17);
uniform vec3 rock_light = vec3(.36,.37,.29);
uniform vec3 moss_dark = vec3(.075,.14,.025);
uniform vec3 moss_light = vec3(.26,.33,.075);
varying vec3 world_position;
varying vec3 world_normal;
float hash(vec3 p) { return fract(sin(dot(p, vec3(127.1,311.7,74.7)))*43758.5453); }
float grain(vec3 p) {
 vec3 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() {
 world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}
void fragment() {
 float broad=grain(world_position*2.4);
 float fine=grain(world_position*28.0);
 float strata=sin(world_position.y*17.0+grain(world_position*1.2)*4.0);
 float crevice=smoothstep(.72,.98,strata)*(.35+grain(world_position*3.0)*.35);
 vec3 stone=mix(rock_dark,rock_light,broad);
 float moss=smoothstep(.18,.72,world_normal.y+(.5-broad)*.55);
 moss=max(moss,smoothstep(.60,.82,broad)*.55);
 vec3 green=mix(moss_dark,moss_light,broad);
 ALBEDO=pow(mix(stone,green,moss),vec3(1.75))*(.87+fine*.2)*(1.0-crevice*.4);
 ROUGHNESS=.96;
}
