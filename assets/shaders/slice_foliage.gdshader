shader_type spatial;
render_mode cull_disabled;
uniform vec4 leaf_color : source_color = vec4(.08,.20,.025,1.0);
void vertex(){
 float weight=clamp((VERTEX.y-1.4)*.4,0.0,1.0);
 VERTEX.x+=sin(TIME*1.4+VERTEX.x*.8+VERTEX.z*.7)*.07*weight;
 VERTEX.z+=sin(TIME*1.1+VERTEX.x*.5+VERTEX.y)*.035*weight;
}
void fragment(){ALBEDO=leaf_color.rgb;ROUGHNESS=.9;SPECULAR=.18;}
