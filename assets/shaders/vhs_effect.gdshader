shader_type canvas_item;

uniform float scanline_strength: hint_range(0.0, 1.0) = 0.12;
uniform float chromatic_aberration: hint_range(0.0, 0.02) = 0.003;
uniform float noise_strength: hint_range(0.0, 1.0) = 0.04;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// Aberración cromática: desplaza canales R y B en horizontal
	float r = textureLod(screen_texture, uv + vec2(chromatic_aberration, 0.0), 0.0).r;
	float g = textureLod(screen_texture, uv, 0.0).g;
	float b = textureLod(screen_texture, uv - vec2(chromatic_aberration, 0.0), 0.0).b;
	vec4 col = vec4(r, g, b, 1.0);

	// Scanlines: oscurece cada segunda línea de píxeles
	float line = mod(floor(uv.y / SCREEN_PIXEL_SIZE.y), 2.0);
	col.rgb *= 1.0 - line * scanline_strength;

	// Ruido estático sutil, varía con el tiempo
	float noise = rand(uv + vec2(fract(TIME * 17.3), fract(TIME * 7.1))) * noise_strength;
	col.rgb = clamp(col.rgb + vec3(noise - noise_strength * 0.5), 0.0, 1.0);

	COLOR = col;
}
