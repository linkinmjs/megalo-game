// Efecto VHS sutil: legible la mayor parte del tiempo, con interferencias ocasionales.
// Sin scanlines constantes — solo jitter horizontal, aberración cromática y ruido estático leve.

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear;

uniform float effect_intensity:   hint_range(0.0, 1.0) = 0.7;   /// Intensidad global del efecto

// Aberración cromática
uniform float chromatic_base:  hint_range(0.0, 0.01)  = 0.0008; /// Aberración siempre presente (casi invisible)
uniform float chromatic_spike: hint_range(0.0, 0.02)  = 0.006;  /// Aberración extra durante interferencias

// Interferencias ocasionales
uniform float glitch_frequency: hint_range(0.1, 5.0)  = 1.0;    /// Pulsos de interferencia por segundo (aprox)
uniform float glitch_strength:  hint_range(0.0, 0.03) = 0.010;  /// Desplazamiento horizontal del jitter

// Ruido estático
uniform float noise_strength:   hint_range(0.0, 0.2)  = 0.025;  /// Intensidad del grano (bajo = sutil)

// Onda de cinta (drift muy sutil, siempre presente)
uniform float tape_wave:        hint_range(0.0, 0.005) = 0.0015; /// Oscilación horizontal de la imagen

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// ── Onda de cinta: drift horizontal lento y muy sutil ────────────────────
	uv.x += (rand(vec2(uv.y * 0.07, TIME * 0.12)) - 0.5) * tape_wave;

	// ── Interferencia ocasional ──────────────────────────────────────────────
	// Cada segmento de 1/glitch_frequency segundos tiene una probabilidad de glitch.
	// smoothstep hace que solo los valores altos (top ~20%) activen el efecto.
	float seg      = floor(TIME * glitch_frequency);
	float seg_val  = rand(vec2(seg, 0.571));
	float glitch   = smoothstep(0.80, 0.98, seg_val) * effect_intensity;

	// Jitter horizontal en franjas aleatorias (no en toda la pantalla)
	float line_seed = rand(vec2(floor(uv.y * 140.0), seg));
	float line_mask = step(0.82, line_seed);  // ~18 % de las líneas afectadas
	uv.x += (rand(vec2(uv.y * 90.0, TIME * 4.0)) - 0.5) * glitch_strength * glitch * line_mask;

	// ── Aberración cromática ─────────────────────────────────────────────────
	float aber = chromatic_base + chromatic_spike * glitch;
	float r = texture(screen_texture, uv + vec2(aber,  0.0)).r;
	float g = texture(screen_texture, uv               ).g;
	float b = texture(screen_texture, uv - vec2(aber,  0.0)).b;
	vec4 col = vec4(r, g, b, 1.0);

	// ── Ruido estático ───────────────────────────────────────────────────────
	// Siempre presente pero muy bajo; se intensifica levemente durante glitches.
	float noise        = rand(uv + vec2(fract(TIME * 17.3), fract(TIME * 7.1)));
	float noise_amount = noise_strength * (0.35 + 0.65 * glitch);
	col.rgb = clamp(col.rgb + vec3(noise * noise_amount - noise_amount * 0.5), 0.0, 1.0);

	COLOR = col;
}
