shader_type canvas_item;

// 暗角效果 — 調查場景常駐
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);
	float vignette = smoothstep(0.3, 0.7 * vignette_intensity + 0.5, dist);
	vec4 original = texture(TEXTURE, uv);
	COLOR = mix(original, vignette_color, vignette * vignette_opacity);
}
