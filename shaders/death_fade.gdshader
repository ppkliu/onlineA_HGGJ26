shader_type canvas_item;

// 死亡紅色褪入黑暗效果
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 death_color : source_color = vec4(0.6, 0.0, 0.0, 1.0);

void fragment() {
	vec4 original = texture(TEXTURE, UV);

	// 階段 1 (0.0 ~ 0.5): 原色 → 紅色
	// 階段 2 (0.5 ~ 1.0): 紅色 → 黑色
	vec3 result;
	if (progress < 0.5) {
		float t = progress * 2.0;
		result = mix(original.rgb, death_color.rgb, t);
	} else {
		float t = (progress - 0.5) * 2.0;
		result = mix(death_color.rgb, vec3(0.0), t);
	}

	COLOR = vec4(result, original.a);
}
