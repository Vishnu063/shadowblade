shader_type spatial;
render_mode cull_disabled;
varying vec3 local_pos;
void vertex(){local_pos=VERTEX;}
void fragment(){
 float x=local_pos.x;float y=local_pos.y;
 float streak=sin(x*88.0+sin(x*17.0)*2.0+sin(y*2.0+TIME*3.0)*.4)*.5+.5;
 float flow=sin(y*31.0+TIME*12.0+x*8.0)*.5+.5;
 float fine=sin(y*73.0+TIME*22.0+x*31.0)*.5+.5;
 ALBEDO=mix(vec3(.11,.25,.28),vec3(.60,.72,.71),.25+streak*.23+flow*.13+fine*.06);
 ROUGHNESS=.38;METALLIC=.05;
}
