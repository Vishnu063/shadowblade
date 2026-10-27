shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled;
uniform sampler2D background_texture : source_color, filter_linear_mipmap;
void fragment() { ALBEDO = texture(background_texture, UV).rgb; }
