// Aberración cromática: split de canales RGB con intensidad controlada por boost.
// boost = 0.0 → separación sutil (apenas perceptible).
// boost = 1.0 → split extremo, canales muy separados.

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear;

uniform float separation_base: hint_range(0.0, 0.01) = 0.0;    /// Split RGB en estado base (0 = apagado)
uniform float separation_max:  hint_range(0.0, 0.05) = 0.035;  /// Split RGB al máximo potenciado

// Potenciado por el director (F7): 0.0 = base, 1.0 = máximo exagerado
uniform float boost: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float sep = mix(separation_base, separation_max, boost);

	float r = texture(screen_texture, SCREEN_UV + vec2(sep,  0.0)).r;
	float g = texture(screen_texture, SCREEN_UV              ).g;
	float b = texture(screen_texture, SCREEN_UV - vec2(sep,  0.0)).b;

	COLOR = vec4(r, g, b, 1.0);
}
