shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 deep_color : source_color = vec4(0.12, 0.46, 0.56, 1.0);
uniform vec4 foam_color : source_color = vec4(0.75, 0.94, 0.91, 1.0);
uniform float flow_speed = 0.6;
void fragment() {
	float bend = sin(UV.y * 12.0 + TIME * 0.9) * 0.03;
	float ribbons = sin((UV.x + bend) * 42.0 + sin(UV.y * 16.0 - TIME * flow_speed * 12.0));
	float foam = smoothstep(0.76, 1.0, ribbons) * 0.42;
	float edges = smoothstep(0.38, 0.5, abs(UV.x - 0.5));
	float streak = pow(max(0.0, sin(UV.y * 45.0 + TIME * flow_speed * 20.0 + UV.x * 8.0)), 16.0) * 0.2;
	ALBEDO = mix(deep_color.rgb, foam_color.rgb, 0.38 + foam * 0.6 + edges * 0.3 + streak * 0.4);
}
