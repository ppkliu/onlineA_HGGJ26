shader_type canvas_item;

// 昏黃回憶色調濾鏡 — 回憶片段 / 序章重播
uniform float sepia_intensity : hint_range(0.0, 1.0) = 0.7;
uniform float brightness : hint_range(0.5, 1.5) = 0.9;

void fragment() {
	vec4 original = texture(TEXTURE, UV);

	// 灰度轉換
	float gray = dot(original.rgb, vec3(0.299, 0.587, 0.114));

	// Sepia 色調
	vec3 sepia = vec3(
		gray * 1.2,
		gray * 1.0,
		gray * 0.8
	);

	vec3 result = mix(original.rgb, sepia, sepia_intensity) * brightness;
	COLOR = vec4(result, original.a);
}
