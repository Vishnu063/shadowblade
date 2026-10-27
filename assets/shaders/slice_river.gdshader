shader_type spatial;
varying vec3 local_pos;
void vertex(){local_pos=VERTEX;VERTEX.y+=sin(VERTEX.x*1.4+TIME*.8)*.018+sin(VERTEX.z*2.4+TIME*1.1)*.012;}
void fragment(){
 float ripple=sin(local_pos.x*12.0+TIME*1.5+sin(local_pos.z*7.0))*sin(local_pos.z*17.0-TIME*1.2);
 ALBEDO=mix(vec3(.035,.12,.13),vec3(.13,.26,.25),ripple*.18+.35);
 NORMAL=normalize(vec3(sin(local_pos.x*9.0+TIME)*.075,sin(local_pos.z*13.0-TIME*1.2)*.07,1.0));
 ROUGHNESS=.24;METALLIC=.28;SPECULAR=.65;
}
