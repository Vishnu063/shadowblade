shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled;
uniform sampler2D art_texture : source_color, filter_linear;
uniform vec4 glow_color : source_color=vec4(1.0,.8,.3,1.0);
uniform float opacity=.2;
void fragment(){
 vec4 art=texture(art_texture,UV);
 float light=dot(art.rgb,vec3(.2126,.7152,.0722));
 ALBEDO=glow_color.rgb*(.55+light*.65);
 ALPHA=art.a*opacity;
}
