shader_type spatial;
varying vec3 position_world;
varying vec3 normal_world;
float hash(vec3 p){return fract(sin(dot(p,vec3(17.13,61.47,38.29)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){position_world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;normal_world=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);}
void fragment(){
 float n=noise(position_world*2.2)*.6+noise(position_world*7.0)*.25+noise(position_world*29.0)*.15;
 vec3 rock=mix(vec3(.075,.095,.10),vec3(.29,.31,.29),smoothstep(.15,.85,n));
 float moss=smoothstep(.2,.7,normal_world.y)*smoothstep(.35,.65,noise(position_world*3.0+5.0));
 ALBEDO=mix(rock,vec3(.04,.09,.013),moss*.8);
 ROUGHNESS=.94;
}
