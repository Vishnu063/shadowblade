shader_type spatial;
render_mode unshaded, cull_disabled;
uniform bool horizontal = false;
float hash(vec2 p) {vec3 q=fract(vec3(p.xyx)*.1031); q+=dot(q,q.yzx+33.33); return fract((q.x+q.y)*q.z);}
float noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void fragment() {
 vec2 uv=UV;
 float flow=TIME*1.3;
 float n=noise(vec2(uv.x*48.0,uv.y*6.0-flow*3.0));
 float fine=noise(vec2(uv.x*110.0,uv.y*25.0-flow*10.0));
 float long_streak=noise(vec2(uv.x*23.0,uv.y*2.0-flow));
 float foam=smoothstep(0.31,0.75,n*0.6+fine*0.23+long_streak*0.4);
 if(horizontal) {
  foam=smoothstep(.65,.95,noise(uv*vec2(13.0,45.0)+vec2(flow*.25,0)))*.4;
  ALBEDO=mix(vec3(.065,.24,.32),vec3(.77,.88,.85),foam);
  ALPHA=.92;
 } else {
  float edge=smoothstep(.0,.09,uv.x)*smoothstep(1.0,.91,uv.x);
  ALBEDO=mix(vec3(.24,.47,.57),vec3(.86,.94,.96),foam);
  ALPHA=edge*(.72+foam*.28);
 }
}
