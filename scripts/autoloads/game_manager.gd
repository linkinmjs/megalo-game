extends Node
## Singleton global del juego.
## Gestiona señales entre sistemas, transiciones de escena y el overlay de shaders.

# ── Señales globales ───────────────────────────────────────────────────────────
signal event_director(event_name: String)
signal background_change()
signal wind_toggled(active: bool)
signal rain_toggled(active: bool)
signal birds_toggled(active: bool)
signal obstacle_intensity_changed(level: int)
signal shader_changed(index: int)

# ── Estado compartido ──────────────────────────────────────────────────────────
## Referencia al AudioStreamPlayer de música. La asigna scenes/main.tscn al cargar.
var music_player: AudioStreamPlayer = null
## Escena a la que volver desde Settings (se setea antes de ir a Settings).
var settings_return_scene: String = "main_menu"

# ── VHS — uniforms ajustables desde el Inspector ───────────────────────────────
@export_group("VHS")
@export var vhs_effect_intensity:   float = 0.7    ## Intensidad global (0=off, 1=máximo)
@export var vhs_glitch_frequency:   float = 1.0    ## Pulsos de interferencia por segundo
@export var vhs_glitch_strength:    float = 0.010  ## Desplazamiento del jitter horizontal
@export var vhs_chromatic_base:     float = 0.0008 ## Aberración cromática base (siempre)
@export var vhs_chromatic_spike:    float = 0.006  ## Aberración extra durante interferencias
@export var vhs_noise_strength:     float = 0.025  ## Grano estático (bajo = sutil)
@export var vhs_tape_wave:          float = 0.0015 ## Drift horizontal de cinta (siempre)

# ── Rutas de escenas ───────────────────────────────────────────────────────────
const SCENES: Dictionary = {
	"main_menu": "res://scenes/menus/main_menu.tscn",
	"game":      "res://scenes/main.tscn",
	"settings":  "res://scenes/menus/settings_menu.tscn",
}

# ── Nodos internos ─────────────────────────────────────────────────────────────
var _overlay: ColorRect
var _transition_layer: CanvasLayer
var _shader_layer: CanvasLayer
var _shader_rect: ColorRect
var _changing_scene: bool = false

# ── Shaders ─────────────────────────────────────────────────────────────────────
var _shader_materials: Array[ShaderMaterial] = []  ## [0]=VHS, [1]=AberraciónCromática, [2]=Pixelado
var _shader_index: int = 0                         ## Índice del shader activo
var _active_material: ShaderMaterial = null        ## Referencia directa al material activo

func _ready() -> void:
	_setup_shader_layer()
	_setup_transition_overlay()

# ── Shader layer ────────────────────────────────────────────────────────────────
func _setup_shader_layer() -> void:
	_shader_layer = CanvasLayer.new()
	_shader_layer.layer = 50
	_shader_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_shader_layer)

	_shader_rect = ColorRect.new()
	_shader_rect.color = Color(1.0, 1.0, 1.0, 1.0)
	_shader_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shader_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shader_layer.add_child(_shader_rect)

	_shader_materials.resize(3)

	# Material 0 — VHS (parámetros desde @export para ajuste desde Inspector)
	var vhs_shader := load("res://assets/shaders/vhs_effect.gdshader") as Shader
	if vhs_shader:
		var mat := ShaderMaterial.new()
		mat.shader = vhs_shader
		mat.set_shader_parameter("effect_intensity",   vhs_effect_intensity)
		mat.set_shader_parameter("glitch_frequency",   vhs_glitch_frequency)
		mat.set_shader_parameter("glitch_strength",    vhs_glitch_strength)
		mat.set_shader_parameter("chromatic_base",     vhs_chromatic_base)
		mat.set_shader_parameter("chromatic_spike",    vhs_chromatic_spike)
		mat.set_shader_parameter("noise_strength",     vhs_noise_strength)
		mat.set_shader_parameter("tape_wave",          vhs_tape_wave)
		_shader_materials[0] = mat

	# Material 1 — Aberración cromática
	var ca_shader := load("res://assets/shaders/chromatic_aberration.gdshader") as Shader
	if ca_shader:
		var mat := ShaderMaterial.new()
		mat.shader = ca_shader
		_shader_materials[1] = mat

	# Material 2 — Pixelado
	var px_shader := load("res://assets/shaders/pixelate.gdshader") as Shader
	if px_shader:
		var mat := ShaderMaterial.new()
		mat.shader = px_shader
		_shader_materials[2] = mat

	# Aplicar shader inicial (VHS, índice 0)
	_active_material = _shader_materials[0]
	if _active_material:
		_shader_rect.material = _active_material

# ── API pública de shaders ──────────────────────────────────────────────────────
func set_active_shader(index: int) -> void:
	if index == _shader_index:
		return
	_shader_index = index
	_active_material = _shader_materials[index]
	if _active_material:
		_active_material.set_shader_parameter("boost", 0.0)
		_shader_rect.material = _active_material
	shader_changed.emit(index)

func apply_shader_boost(t: float) -> void:
	if _active_material:
		_active_material.set_shader_parameter("boost", t)

# ── Overlay de transición ──────────────────────────────────────────────────────
func _setup_transition_overlay() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100
	_transition_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_transition_layer)

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_layer.add_child(_overlay)

# ── Cambio de escena con fade ──────────────────────────────────────────────────
func change_scene(scene_key: String, return_scene: String = "") -> void:
	if _changing_scene:
		return
	if scene_key not in SCENES:
		push_error("GameManager: escena desconocida '%s'" % scene_key)
		return
	if return_scene != "":
		settings_return_scene = return_scene

	_changing_scene = true
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.35)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(SCENES[scene_key])
	)
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void:
		_changing_scene = false
	)
