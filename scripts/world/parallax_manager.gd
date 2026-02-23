class_name ParallaxManager
extends Node2D
## Gestiona el scroll automático del fondo parallax y el cambio de fondos (F1).
## Soporta múltiples sets de fondos con cross-fade de fade_duration segundos entre cambios.
## Los sprites se crean dinámicamente en _ready(); no se necesitan hijos en la escena.

@export var scroll_speed: float  = 80.0   ## Velocidad de scroll horizontal (px/s)
@export var fade_duration: float = 1.5    ## Duración del cross-fade al cambiar fondo (s)

# ── Sets de fondo ───────────────────────────────────────────────────────────────
## Cada entrada define las texturas para las 3 capas: far, mid, front.
## Agregar más entradas para tener más fondos ciclables con F1.
const BACKGROUND_SETS: Array = [
	{
		"far":   "res://assets/backgrounds/sky_clouds/set_01/layer_01.png",
		"mid":   "res://assets/backgrounds/sky_clouds/set_01/layer_02.png",
		"front": "res://assets/backgrounds/sky_clouds/set_01/layer_03.png",
	},
	{
		"far":   "res://assets/backgrounds/sky_clouds/set_03/layer_01.png",
		"mid":   "res://assets/backgrounds/sky_clouds/set_03/layer_02.png",
		"front": "res://assets/backgrounds/sky_clouds/set_03/layer_03.png",
	},
	{
		"far":   "res://assets/backgrounds/post_apocalypse/set_01/layer_01.png",
		"mid":   "res://assets/backgrounds/post_apocalypse/set_01/layer_02.png",
		"front": "res://assets/backgrounds/post_apocalypse/set_01/layer_03.png",
	},
]

# ── Nodos ──────────────────────────────────────────────────────────────────────
@onready var parallax_bg:      ParallaxBackground = $ParallaxBackground
@onready var sky_far:          ParallaxLayer = $ParallaxBackground/SkyFar
@onready var clouds_mid:       ParallaxLayer = $ParallaxBackground/CloudsMid
@onready var elements_front:   ParallaxLayer = $ParallaxBackground/ElementsFront

# ── Estado ─────────────────────────────────────────────────────────────────────
var _current_index: int = 0
var _fading: bool = false
var _layers: Array[ParallaxLayer] = []
# Dos sprites por capa para cross-fade verdadero: A=fondo visible, B=fondo siguiente
var _sprites_a: Array[Sprite2D] = []
var _sprites_b: Array[Sprite2D] = []

func _ready() -> void:
	_layers = [sky_far, clouds_mid, elements_front]
	_create_layer_sprites()
	_load_background(_current_index, _sprites_a)
	GameManager.background_change.connect(_on_background_change)

func _process(delta: float) -> void:
	parallax_bg.scroll_base_offset.x -= scroll_speed * delta

# ── Creación de sprites ─────────────────────────────────────────────────────────
func _create_layer_sprites() -> void:
	# Con cámara DRAG_CENTER en (0,0), el viewport va de (-half_vp) a (+half_vp).
	# Los sprites deben comenzar en (-half_vp) para cubrir desde la esquina superior-izquierda.
	var half_vp: Vector2 = get_viewport_rect().size * 0.5
	var start_pos := Vector2(-half_vp.x, -half_vp.y)
	for i in _layers.size():
		var sprite_a := _make_sprite(start_pos)
		var sprite_b := _make_sprite(start_pos)
		sprite_b.modulate.a = 0.0
		_layers[i].add_child(sprite_a)
		_layers[i].add_child(sprite_b)
		_sprites_a.append(sprite_a)
		_sprites_b.append(sprite_b)

func _make_sprite(pos: Vector2 = Vector2.ZERO) -> Sprite2D:
	var s := Sprite2D.new()
	s.centered = false
	s.position = pos
	return s

# ── Carga de texturas ───────────────────────────────────────────────────────────
func _load_background(index: int, sprites: Array[Sprite2D]) -> void:
	if BACKGROUND_SETS.is_empty():
		return
	var set_data: Dictionary = BACKGROUND_SETS[index % BACKGROUND_SETS.size()]
	var vp_size: Vector2 = get_viewport_rect().size
	var keys := ["far", "mid", "front"]
	for i in sprites.size():
		var path: String = set_data.get(keys[i], "")
		if path == "" or not ResourceLoader.exists(path):
			push_warning("ParallaxManager: textura no encontrada — " + path)
			continue
		sprites[i].texture = load(path)
		# Escalar el sprite para que la imagen llene exactamente el alto del viewport.
		# Las imágenes son pixel art (576×324); el factor lleva 324→720 sin distorsión
		# porque el aspect ratio 16:9 coincide con el del viewport.
		var tex_size: Vector2 = sprites[i].texture.get_size()
		var scale_factor: float = vp_size.y / tex_size.y if tex_size.y > 0.0 else 1.0
		sprites[i].scale = Vector2(scale_factor, scale_factor)
		# motion_mirroring = ancho escalado → tiling sin costura
		_layers[i].motion_mirroring = Vector2(tex_size.x * scale_factor, 0.0)

# ── Cambio de fondo con cross-fade ─────────────────────────────────────────────
func next_background() -> void:
	if _fading:
		return
	_fading = true
	_current_index = (_current_index + 1) % BACKGROUND_SETS.size()
	_load_background(_current_index, _sprites_b)

	var tween := create_tween().set_parallel(true)
	for i in _sprites_a.size():
		tween.tween_property(_sprites_a[i], "modulate:a", 0.0, fade_duration)
		tween.tween_property(_sprites_b[i], "modulate:a", 1.0, fade_duration)
	tween.finished.connect(_on_fade_complete, CONNECT_ONE_SHOT)

func _on_fade_complete() -> void:
	# Intercambiar referencias: A pasa a ser el visible, B queda lista para el próximo cambio
	var tmp: Array[Sprite2D] = _sprites_a
	_sprites_a = _sprites_b
	_sprites_b = tmp
	for s in _sprites_b:
		s.modulate.a = 0.0
	_fading = false

func _on_background_change() -> void:
	next_background()
