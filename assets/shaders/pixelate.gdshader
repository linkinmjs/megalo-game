// Pixelado retro: reduce la resolución aparente de la pantalla.
// boost = 0.0 → pixelado sutil, look retro suave.
// boost = 1.0 → píxeles muy grandes, aspecto 8-bit exagerado.

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform float pixel_size_base: hint_range(1.0, 8.0)  = 1.0;   /// Tamaño de píxel en estado base (1 = sin efecto)
uniform float pixel_size_max:  hint_range(8.0, 32.0) = 20.0;  /// Tamaño de píxel al máximo potenciado

// Potenciado por el director (F7): 0.0 = base, 1.0 = máximo exagerado
uniform float boost: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float psize = mix(pixel_size_base, pixel_size_max, boost);

	// SCREEN_PIXEL_SIZE = tamaño de un píxel en espacio UV → su inverso = resolución en px
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixelated_uv = floor(SCREEN_UV * screen_size / psize) * psize / screen_size;

	COLOR = texture(screen_texture, pixelated_uv);
}
